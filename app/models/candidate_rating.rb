# TODO: remove comments, now they are deprecated
class CandidateRating < ApplicationRecord
  belongs_to :candidate_vacancy
  belongs_to :commenter, class_name: 'Account'
  belongs_to :vacancy_stage

  before_destroy { CandidateChange.where(change_for: self).destroy_all }

  after_save :update_history

  enum rating_type: %i[passing five_stars ten_stars], _suffix: true

  private

  def update_history
    candidate_vacancy.candidate.update_history('rated', updated_at, candidate_vacancy.vacancy, self) if value.present?
  end
end
