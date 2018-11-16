class VacancyStage < ApplicationRecord
  enum group_name: {
    screening: 1,
    testing: 2,
    interviewing: 3,
    decision: 4
  }

  enum type_of_rating: {
    passing: 1,
    five_point_scale: 2,
    ten_point_scale: 3
  }

  attr_accessor :rated
  attr_accessor :unrated

  before_destroy { CandidateChange.where(change_for: self).destroy_all }

  belongs_to :vacancy, foreign_key: :vacancy_id, required: false
  belongs_to :template_stage, required: false
  belongs_to :vacancy_stage_group, required: false
  # has_many :vacancy_stage_subscriptions, dependent: :destroy, foreign_key: :vacancy_stage_id
  # has_many :users, through: :vacancy_stage_subscriptions
  has_many :candidate_vacancies, foreign_key: :current_vacancy_stage_id
  has_many :candidates, through: :candidate_vacancies
  has_many :candidate_ratings, dependent: :destroy

  acts_as_tenant :company

  after_save { vacancy&.touch }

  #accepts_nested_attributes_for :users, reject_if: :all_blank, allow_destroy: true

  def candidates_count
    candidate_vacancies_count
  end
end
