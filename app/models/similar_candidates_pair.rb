class SimilarCandidatesPair < ApplicationRecord
  belongs_to :first_candidate, class_name: 'Candidate', foreign_key: :first_candidate_id, inverse_of: :similar_candidates_pairs_as_first
  belongs_to :second_candidate, class_name: 'Candidate', foreign_key: :second_candidate_id, inverse_of: :similar_candidates_pairs_as_second

  validates_uniqueness_of :second_candidate_id, scope: [:first_candidate_id]
  validate :pair_of_candidates_is_unique

  scope :checked, -> {where(checked: true)}
  scope :unchecked, -> {where(checked: false)}

  def save_both!
    update(checked: true)
  end

  def save_first!
    first_candidate.absorb_another_candidate(second_candidate)
  end

  def save_second!
    second_candidate.absorb_another_candidate(first_candidate)
  end

  def self.pair_exists?(first_id, second_id)
    where(first_candidate_id: first_id, second_candidate_id: second_id).or(where(first_candidate_id: second_id, second_candidate_id: first_id)).any?
  end

  def self.find_pair(first_id, second_id)
    find_by(first_candidate_id: first_id, second_candidate_id: second_id) || find_by(first_candidate_id: second_id, second_candidate_id: first_id)
  end

  def save_candidate_by_id(id)
    if first_candidate_id == id
      save_first!
    elsif second_candidate_id == id
      save_second!
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def pair_of_candidates_is_unique
    errors.add(:first_candidate_id, 'Пара должна быть уникальной') unless SimilarCandidatesPair.find_by(first_candidate_id: second_candidate_id, second_candidate_id: first_candidate_id).blank?
  end
end
