class VacancyStageGroup < ApplicationRecord
  has_many :vacancy_stages
  has_many :candidates, through: :vacancy_stages

  scope :default_order, -> { order(position: :asc) }

  acts_as_tenant :company

  def candidates_count
    candidates.distinct.count
    #Candidate.includes(candidate_vacancies:[:current_vacancy_stage]).where("candidate_vacancies" => {"vacancy_stages" => {"vacancy_stage_group_id" => id}}).count
  end

  def self.candidates_count
    joins(:vacancy_stages => :candidates).group('vacancy_stage_groups.id').count('DISTINCT candidates.id')
  end
end
