class CandidateVacancy < ApplicationRecord
  include Indexable
  include Elasticsearch::Model
  belongs_to :candidate
  belongs_to :vacancy

  belongs_to :current_vacancy_stage, class_name: 'VacancyStage', foreign_key: :current_vacancy_stage_id, counter_cache: true

  has_many :candidate_ratings, dependent: :destroy
  has_one :current_candidate_rating, -> { joins(' INNER JOIN candidate_vacancies ON candidate_vacancies.id = candidate_ratings.candidate_vacancy_id AND candidate_vacancies.current_vacancy_stage_id = candidate_ratings.vacancy_stage_id').where.not(value: nil).order(created_at: :desc) }, class_name: 'CandidateRating', dependent: :destroy, foreign_key: :candidate_vacancy_id
  has_many :comments, as: :commentable, dependent: :destroy

  after_create { candidate.update_history('vacancy_attached', created_at, vacancy) }
  after_create :notify_attached
  before_destroy { CandidateChange.where(vacancy_id: id).destroy_all }
  before_save :update_history_on_stage_change

  settings index: {
    number_of_shards: 1,
    analysis: {
      analyzer: {
        trigram: {
          tokenizer: 'trigram',
          filter: [:lowercase]
        }
      },
      tokenizer: {
        trigram: {
          type: 'edge_ngram',
          min_gram: 2,
          max_gram: 20,
          token_chars: %w[letter digit]
        }
      }
    }
  } do
    mapping do
      indexes 'candidate.first_name', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
      indexes 'candidate.last_name', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
      indexes 'candidate.middle_name', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
    end
  end

  accepts_nested_attributes_for :candidate_ratings, reject_if: :all_blank, allow_destroy: true

  validate :vacancy_stage_must_belongs_to_current_vacancy
  validates_uniqueness_of :candidate_id, scope: :vacancy_id
  before_save :notify_offer

  def next_vacancy_stage
    stages = vacancy.vacancy_stages.to_a
    index = stages.index { |x| x.id == current_vacancy_stage_id }
    stages[index + 1] if index && (index + 1 < stages.size)
  end

  def candidate_changes
    @candidate_changes ||= candidate.candidate_changes.where(vacancy_id: vacancy_id)
  end

  def candidate_changes_as_json
    CandidateChange::EagerLoader.preload(candidate_changes)
    candidate_changes.as_json(
      include: {
        account: {
          only: %i[id photo],
          methods: :full_name
        },
        change_for: {}
      }
    )
  end

  def self.search(query, vacancy_id)
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    search_query = query || ''
    # escaping reserved symbols
    reserved_symbols.each do |s|
      search_query.gsub!(s, "\\#{s}")
    end
    __elasticsearch__.search(
      query: {
        bool: {
          must: [
            {
              bool: {
                should: [
                  {
                    multi_match: {
                      query: search_query,
                      type: 'cross_fields',
                      fields: %w[candidate.last_name candidate.first_name candidate.middle_name],
                      boost: 4
                    }
                  },
                  {
                    multi_match: {
                      query: search_query,
                      type: 'cross_fields',
                      analyzer: 'trigram',
                      fields: %w[candidate.last_name.trigram candidate.first_name.trigram candidate.middle_name.trigram],
                      minimum_should_match: '100%'
                    }
                  }
                ]
              }
            },
            {
              term: {
                vacancy_id: vacancy_id
              }
            }
          ]
        }
      }
    )
  end

  def as_indexed_json(options = {})
    as_json(
      only: %i[vacancy_id current_vacancy_stage_id],
      include: {
        candidate: {
          only: %i[first_name middle_name last_name]
        }
      }
    )
  end

  def other_vacancies_count
    candidate.candidate_vacancies_in_use.where.not(vacancy_id: vacancy_id).count
  end

  private

  def set_default_stage
    self.current_vacancy_stage = vacancy.vacancy_stages.order(:position).first
  end

  def vacancy_stage_must_belongs_to_current_vacancy
    set_default_stage if (current_vacancy_stage_id.nil? && vacancy_id.present?)
    if vacancy_id.present? && !vacancy.vacancy_stages.map(&:id).include?(current_vacancy_stage_id)
      errors.add(:current_vacancy_stage, 'Этап должен принадлежать вакансии')
    end
  end

  def notify_attached
    vacancy_data = {name: vacancy&.name, id: vacancy&.id}
    candidate_data = {name: candidate&.full_name, id: candidate&.id}
    DchCandidateNotificationsWorker.perform_async(vacancy_data, candidate_data, :attached, vacancy&.creator&.uid)
  end

  def notify_offer
    if valid? && current_vacancy_stage_id_changed? && persisted?
      if current_vacancy_stage&.name == 'Оффер принят'
        AutoNotificationsMailer.offer_status_changed(candidate&.full_name, vacancy&.name, 'принял оффер', vacancy&.creator&.email).deliver_later
        DchCandidateNotificationsWorker.perform_async({name: vacancy&.name}, {name: candidate&.full_name}, :accept, vacancy&.creator&.uid)
      elsif current_vacancy_stage&.name == 'Отказ' && VacancyStage.find_by_id(current_vacancy_stage_id_was)&.name == 'Оффер выставлен'
        AutoNotificationsMailer.offer_status_changed(candidate&.full_name, vacancy&.name, 'отказался от оффера', vacancy&.creator&.email).deliver_later
        DchCandidateNotificationsWorker.perform_async({name: vacancy&.name}, {name: candidate&.full_name}, :reject, vacancy&.creator&.uid)
      end
    end
  end

  def update_history_on_stage_change
    if valid? && current_vacancy_stage_id_changed?
      if current_vacancy_stage&.vacancy_stage_group&.label == 'Принят'
        candidate.update_history('vacancy_stage_changed_to_accepted', DateTime.now, vacancy, current_vacancy_stage)
      elsif current_vacancy_stage&.vacancy_stage_group&.label == 'Архив'
        candidate.update_history('vacancy_stage_changed_to_archived', DateTime.now, vacancy, current_vacancy_stage)
      else
        candidate.update_history('vacancy_stage_changed', DateTime.now, vacancy, current_vacancy_stage) if valid? && current_vacancy_stage_id_changed?
      end
      DchCandidateNotificationsWorker.perform_async({name: vacancy&.name}, {name: candidate&.full_name, status: current_vacancy_stage&.name}, :transition, vacancy&.owner&.uid)
    end
  end
end
