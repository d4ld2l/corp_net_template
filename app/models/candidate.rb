class Candidate < ApplicationRecord
  include Elasticsearch::Model
  include Indexable
  include TaskableModel
  settings index: { number_of_shards: 1 } do
    mappings do
      indexes 'resume.city', index: 'not_analyzed', type: 'string'
      indexes 'resume.resume_file', type: 'object'
    end
  end

  attr_reader :skip_callbacks

  acts_as_tenant :company

  has_one :resume, -> { where(primary: true) }, inverse_of: :candidate, dependent: :destroy
  has_many :old_resumes, -> { where(primary: false) }, class_name: 'Resume', before_add: :set_resume_private_to_false, dependent: :destroy

  has_one :info360
  has_many :candidate_vacancies, dependent: :destroy

  has_many :candidate_vacancies_active, -> { includes(current_vacancy_stage: :vacancy_stage_group).where.not(current_vacancy_stage: { vacancy_stage_groups: { label: 'Архив' } }).where.not(current_vacancy_stage: { vacancy_stage_groups: { label: 'Принят' } }).where.not(current_vacancy_stage: { vacancy_stage_groups: { label: 'Отказ' } }).references(:vacancy_stages => :vacancy_stage_groups) }, class_name: 'CandidateVacancy', dependent: :destroy
  has_many :candidate_vacancies_in_use, -> { includes(current_vacancy_stage: :vacancy_stage_group).where.not(current_vacancy_stage: { vacancy_stage_groups: { label: 'Архив' } }).references(:vacancy_stages => :vacancy_stage_groups) }, class_name: 'CandidateVacancy', dependent: :destroy

  has_many :vacancies, through: :candidate_vacancies
  has_many :vacancy_stages, through: :candidate_vacancies, source: :current_vacancy_stage, primary_key: :current_vacancy_stage_id
  has_many :vacancy_stage_groups, through: :vacancy_stages
  has_many :candidate_changes, -> { order(created_at: :desc) }, dependent: :destroy

  has_many :similar_candidates_pairs_as_first, -> { unchecked.joins(:second_candidate).order('candidates.created_at DESC') }, class_name: 'SimilarCandidatesPair', foreign_key: :first_candidate_id, inverse_of: :first_candidate, dependent: :destroy
  has_many :similar_candidates_pairs_as_second, -> { unchecked.joins(:first_candidate).order('candidates.created_at DESC') }, class_name: 'SimilarCandidatesPair', foreign_key: :second_candidate_id, inverse_of: :second_candidate, dependent: :destroy
  has_many :checked_similar_candidates_pairs_as_first, -> { checked.joins(:second_candidate).order('candidates.created_at DESC') }, class_name: 'SimilarCandidatesPair', foreign_key: :first_candidate_id, inverse_of: :first_candidate, dependent: :destroy
  has_many :checked_similar_candidates_pairs_as_second, -> { checked.joins(:first_candidate).order('candidates.created_at DESC') }, class_name: 'SimilarCandidatesPair', foreign_key: :second_candidate_id, inverse_of: :second_candidate, dependent: :destroy

  has_many :similar_candidates_as_first, -> { order(created_at: :desc) }, through: :similar_candidates_pairs_as_first, class_name: 'Candidate', source: :second_candidate
  has_many :similar_candidates_as_second, -> { order(created_at: :desc) }, through: :similar_candidates_pairs_as_second, class_name: 'Candidate', source: :first_candidate

  after_create_commit { CandidateComparerWorker.perform_async(id) }
  after_create { update_history 'created', created_at }
  after_create :parse_Info360
  after_update { update_history 'candidate_edited', updated_at if changes.any? && !skip_callbacks }
  after_touch { update_history 'resume_edited', updated_at unless skip_callbacks }
  after_create :update_resume_if_manual, unless: -> { skip_callbacks }
  after_update :update_resume_if_manual, unless: -> { skip_callbacks }
  after_touch :update_resume_if_manual, unless: -> { skip_callbacks }
  after_touch { Indexer.perform_async(parameters_json('index')) }

  accepts_nested_attributes_for :resume, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :candidate_vacancies, reject_if: :all_blank, allow_destroy: true

  scope :unassigned, -> { left_outer_joins(:candidate_vacancies).where(candidate_vacancies: { vacancy_id: nil }) }

  validates_associated :candidate_vacancies
  validate :candidate_vacancy_duplicates

  def full_name
    "#{last_name} #{first_name} #{middle_name}"
  end

  def update_history(type, date, vacancy = nil, change_for = nil, current_account = nil)
    ca = current_account || RequestStore.store[:current_account]
    candidate_changes.create(change_type: type, timestamp: date || DateTime.current, account: ca, change_for: change_for, vacancy: vacancy) unless ca.blank?
  end

  def similar_candidates
    Candidate.select(:id).where(id: similar_candidates_as_first_ids + similar_candidates_as_second_ids).order(created_at: :desc)
  end

  def parse_Info360
    Info360::Parser.perform_async(id)
  end

  def update_resume_file(path)
    @skip_callbacks = true
    resume&.update(resume_file: Pathname.new(path).open)
    @skip_callbacks = false
  end

  def last_position
    resume&.last_position
  end

  def last_action
    candidate_changes.last&.timestamp
  end

  def age
    return if birthdate.nil?
    ((Time.current - birthdate.to_time) / 1.year).floor
  end

  def last_resume_action
    candidate_changes.where(change_type: 'resume_edited').or(candidate_changes.where(change_type: 'candidate_edited')).or(candidate_changes.where(change_type: 'edited')).last&.timestamp
  end

  def compare_with_other_candidates
    Candidate.where.not(id: id).where(company_id: company_id).each do |cand|
      if (!full_name.blank? && !cand.full_name.blank? && cand.full_name.downcase == full_name.downcase) ||
        (resume&.resume_contacts&.where(contact_type: [:phone, :email])&.map(&:value).to_a & cand.resume&.resume_contacts&.where(contact_type: [:phone, :email])&.map(&:value).to_a).any?
        SimilarCandidatesPair.create(first_candidate_id: id, second_candidate_id: cand.id) unless SimilarCandidatesPair.pair_exists?(id, cand.id)
      end
    end
  end

  def as_indexed_json(options = {})
    as_json(include:
              { resume: {
                include: {
                  resume_work_experiences: {},
                  resume_contacts: {},
                  resume_educations: { include: { education_level: {} } },
                  professional_specializations: { include: { professional_area: {} } },
                  education_level: {},
                  language_skills: { include: { language: {}, language_level: {} } },
                  skills: {}
                },
                methods: [:summary_work_period],
                except: [:resume_file]
              },
                vacancies: {},
                vacancy_stage_groups: {}
              },
            methods: [:last_position])
  end

  def self.search(query, company_id, params = {})
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    search_query = query || ''
    # escaping reserved symbols
    reserved_symbols.each do |s|
      search_query.gsub!(s, "\\#{s}")
    end
    search_array = []
    unless search_query.blank?
      search_array.push({ multi_match: {
        query: search_query.strip,
        fields: %w(last_position resume.resume_work_experiences.position resume.resume_work_experiences.company_name resume.resume_work_experiences.region resume.resume_work_experiences.website resume.resume_work_experiences.experience_description resume.city last_name first_name resume.resume_contacts.value resume_text),
        type: 'cross_fields',
        analyzer: 'standard',
        operator: 'and'
      } })
    end
    search_array += {
      bool: {
        must: {
          term: {
            company_id: company_id
          }
        }
      }
    } if company_id.present?
    unless params.blank?
      search_array += filter_params(params)
    end
    sort_params = sort_params(params)
    return Candidate.where('1=0') if search_array.blank? && sort_params.blank?
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: search_array
          }
        },
        sort: sort_params
      }.compact
    )
  end

  def absorb_another_candidate(another_candidate)
    old_resumes << another_candidate.resume if another_candidate.resume
    self.old_resumes += another_candidate.old_resumes
    self.vacancies += another_candidate.vacancies
    another_candidate.reload
    another_candidate.destroy!
  end

  private

  def candidate_vacancy_duplicates
    if candidate_vacancies.group_by(&:vacancy_id).map { |k, v| v.count > 1 }.any?
      errors.add(:candidate_vacancies, 'Кандидат должен быть уникальным для каждой вакансии')
    end
  end

  def update_resume_if_manual
    if resume&.manual?
      ResumeFileCreatorWorker.perform_async(id)
    end
  end

  def set_resume_private_to_false(resume)
    resume.update(primary: false)
  end

  def self.sort_params(params = {})
    type = params[:sort] || params['sort']
    case type
    when 'salary_asc'
      [{ 'resume.salary_level' => { order: :asc } },
       { created_at: { order: :desc } }]
    when 'salary_desc'
      [{ 'resume.salary_level' => { order: :desc } },
       { created_at: { order: :desc } }]
    else
      [{ _score: { order: :desc } },
       { created_at: { order: :desc } }]
    end
  end

  def self.experience_to_period
    {
      no_experience: {
        gte: 0,
        lt: 12
      },
      from_1_year: {
        gte: 12,
        lt: 36
      },
      for_3_years: {
        lte: 36
      },
      from_3_to_6_years: {
        gte: 36,
        lte: 72
      },
      from_6_years: {
        gt: 72
      }
    }
  end

  def self.filter_params(params = {})
    params.map do |k, v|
      case k.to_s
      when 'working_schedule', 'employment_type', 'city'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { "resume.#{k}" => x } } }
          }
        }
      when 'experience'
        {
          bool: {
            should: v.split(',')&.map { |x| { range: { 'resume.summary_work_period' => experience_to_period[x.to_sym] } } }
          }
        }
      when 'skills', 'professional_specializations'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { "resume.#{k}.id" => x } } }
          }
        }
      when 'vacancy_stage_groups', 'vacancies'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { "#{k}.id" => x } } }
          }
        }
      when 'education_level'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { "resume.resume_educations.education_level.id" => x } } }
          }
        }
      when 'language'
        {
          bool: {
            should: v.split(';')&.map do |x|
              lan = x.split(',')
              terms = [{ term: { 'resume.language_skills.language.id' => lan[0] } }, { term: { 'resume.language_skills.language_level.id' => lan[1] } }].compact
              return nil if terms.blank?
              { bool: { must: terms } }
            end.compact
          }
        }
      else
        nil
      end
    end.compact
  end
end
