module Assessment
  class Session < ApplicationRecord
    self.table_name_prefix = 'assessment_'
    include AASM
    include Elasticsearch::Model

    belongs_to :account
    belongs_to :project_role, class_name: 'Assessment::ProjectRole'
    belongs_to :created_by, class_name: 'Account'
    has_many :participants, foreign_key: :assessment_session_id, class_name: 'Assessment::Participant', dependent: :destroy, validate: true
    has_many :manager_participants, ->{where(kind: :manager)}, foreign_key: :assessment_session_id, class_name: 'Assessment::Participant'
    has_many :associate_participants, ->{where(kind: :associate)}, foreign_key: :assessment_session_id, class_name: 'Assessment::Participant'
    has_many :subordinate_participants, ->{where(kind: :subordinate)}, foreign_key: :assessment_session_id, class_name: 'Assessment::Participant'
    has_many :session_skills, ->{order(position: :asc)}, foreign_key: :assessment_session_id, class_name: 'Assessment::SessionSkill', dependent: :destroy, validate: true
    has_many :skills, through: :session_skills, class_name: 'Skill'
    has_many :session_evaluations, class_name: 'Assessment::SessionEvaluation', foreign_key: :assessment_session_id, dependent: :destroy
    has_many :spectators, class_name: 'Assessment::Spectator', foreign_key: :assessment_session_id, dependent: :destroy

    accepts_nested_attributes_for :participants, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :manager_participants, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :associate_participants, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :subordinate_participants, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :session_skills, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :session_evaluations, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :spectators, reject_if: :all_blank, allow_destroy: true

    scope :available_for_evaluatable, ->(a_id){ includes(:participants, :spectators).where(account_id: a_id).distinct }
    scope :available_for_evaluator, ->(a_id){ includes(:participants, :spectators).where(assessment_participants:{account_id: a_id}).distinct }
    scope :available_for_spectators, ->(a_id){ includes(:participants, :spectators).where(assessment_spectators:{account_id: a_id}).distinct }
    scope :not_done_by, ->(a_id){where("assessment_sessions.id NOT IN (SELECT assessment_session_id from assessment_session_evaluations WHERE assessment_session_evaluations.account_id = #{a_id})").distinct }
    scope :available_for, ->(a_id){ available_for_evaluatable(a_id).or(available_for_evaluator(a_id)) }
    scope :available_for_spectators_or_evaluatable, ->(a_id){ available_for_evaluatable(a_id).or(available_for_spectators(a_id)) }

    enum kind:       %i[ a360 ]
    enum rating_scale: %i[ six ]

    acts_as_tenant :company

    aasm column: :status do
      state :created, initial: true
      state :in_progress, :completed, :closed

      event :to_in_progress, after: :send_invitation_notification do
        transitions from: :created, to: :in_progress
      end

      event :to_completed, after: :send_completed_notification do
        transitions from: :in_progress, to: :completed
      end

      event :to_closed, after: :send_close_notification do
        transitions from: :completed, to: :closed
      end
    end

    mount_base64_uploader :logo, AssessmentSessionUploaderUploader
    mount_uploader :logo, AssessmentSessionUploaderUploader

    before_save :set_default_name
    before_commit :check_completeness
    before_update :prefill_results, if: ->{ status == 'completed' }

    validates_presence_of :account_id, :kind, :rating_scale, :status
    validate :participants_must_be_unique, on: :create
    validate :skills_must_be_unique, on: :create
    validate :spectators_must_be_unique, on: :create

    def as_indexed_json(options={})
      self.as_json(
          only: %i[ kind status name created_at ],
          include: {
              skills: { only: :name },
              account: { only: [:full_name] },
              project_role: { only: [:name] }
          }
      )
    end

    def self.search(query, params={})
      reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
      search_query = query || ''
      # escaping reserved symbols
      reserved_symbols.each do |s|
        search_query.gsub!(s, "\\#{s}")
      end
      es_query = {
          query: {
              bool: {
                  must: filter_array(search_query, params)
              },
          },
          sort: [{ _score: { order: :desc } },
                 { created_at: { order: :desc } }]
      }
      if search_query.present?
        es_query.merge!(
            {
                query: {
                    bool: {
                        should: {
                            multi_match: {
                                query: query,
                                type: 'phrase_prefix',
                                fields: %w[name description skills.name account.full_name project_role.name]
                            }
                        }
                    }
                }
            }
        )
      end
      __elasticsearch__.search( es_query )
    end

    def status_name
      I18n.t("activerecord.attributes.assessment_session.status.#{self.status}")
    end

    def done_by?(a_id)
      session_evaluations.keep_if{|x| x.account_id == a_id}.any?
    end

    def unevaluated_participants
      Assessment::Participant.where(assessment_session_id: self.id, account_id: participants.map(&:account_id) - session_evaluations.map(&:account_id))
    end

    def unevaluated_accounts
      Account.where(id: unevaluated_participants.map(&:account_id) + [account_id])
    end

    def build_report_360
      Assessment::A360::Reports::Docx::Result.new.build_report(self)
    end

    private

    def participants_must_be_unique
      parts = participants.to_a.map(&:account_id)
      if parts.size - parts.uniq.size > 0
        duplicate_ids = parts.select{|x| parts.count(x) > 1}.uniq
        errors.add(:participants, 'Участники должны быть уникальны') # Workaround
        participants.each{|x| x.errors.add(:account_id, 'Участники должны быть уникальны') if duplicate_ids.include?(x.account_id)}
      end
    end

    def skills_must_be_unique
      s = session_skills.to_a.map(&:skill_id)
      if s.size - s.uniq.size > 0
        duplicate_ids = s.select{|x| s.count(x) > 1}.uniq
        errors.add(:skills, 'Компетенции должны быть уникальны') # Workaround
        session_skills.each{|x| x.errors.add(:skill_id, 'Компетенции должны быть уникальны') if duplicate_ids.include?(x.skill_id)}
      end
    end

    def spectators_must_be_unique
      s = spectators.to_a.map(&:account_id)
      if s.size - s.uniq.size > 0
        duplicate_ids = s.select{|x| s.count(x) > 1}.uniq
        errors.add(:spectators, 'Компетенции должны быть уникальны') # Workaround
        spectators.each{|x| x.errors.add(:account_id, 'Наблюдатели должны быть уникальны') if duplicate_ids.include?(x.account_id)}
      end
    end

    def check_completeness
      p_count = (participants.distinct.pluck(&:id) + [account_id]).uniq.count
      if self.status == 'in_progress' && session_evaluations.where(done: true).count == p_count
        to_completed!
      end
    end

    def set_default_name
      if name.empty?
        self.name = "#{I18n.t("activerecord.attributes.assessment_session.kind.#{kind}")}. #{account&.full_name}"
      end
    end

    def prefill_results
      evaluation = ::Assessment::A360::Result::Presenter.new(self).as_json
      of, hf, gd, bs = [], [], [], []
      evaluation[:skills].each do |s|
        case
        when s[:avg_score_self].to_f > 4 && s[:avg_score_not_self].to_f > 4
          of << s['name']
        when s[:avg_score_self].to_f <= 4 && s[:avg_score_not_self].to_f > 4
          hf << s['name']
        when s[:avg_score_self].to_f <= 4 && s[:avg_score_not_self].to_f <= 4
          gd << s['name']
        when s[:avg_score_self].to_f > 4 && s[:avg_score_not_self].to_f <= 4
          bs << s['name']
        end
      end
      self.obvious_fortes ||= of.join(', ')
      self.hidden_fortes ||= hf.join(', ')
      self.growth_direction ||= gd.join(', ')
      self.blind_spots ||= bs.join(', ')
    end

    def send_invitation_notification
      unevaluated_accounts.map{|x| x&.email}.each do |p|
        AssessmentSessionsMailer.invitation_notification(self.account.full_name, self.id, p).deliver_later
      end
    end

    def send_completed_notification
      if created_by
        AssessmentSessionsMailer.completed_notification(self.account.full_name, self.id, created_by&.email).deliver_later
      end
    end

    def send_close_notification
      AssessmentSessionsMailer.close_notification(self.id, account.email).deliver_later
    end

    def self.filter_array(query, params={})
      search_params_array = []
      search_params_array +=
          params.map do |k, v|
            unless v.blank?
              case
              when k == 'kind'
                {
                    bool: {
                        should: v.map {|x| {match: { 'kind' => x}}}
                    }
                }
              when k == 'state'
                {
                    bool: {
                        should: v.map {|x| {match: { 'status' => x}}}
                    }
                }
              end
            end
          end
      search_params_array.compact
    end
  end
end
