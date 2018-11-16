class CandidateChange < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :vacancy, optional: true
  belongs_to :candidate
  belongs_to :change_for, polymorphic: true, optional: true

  enum change_type: %i[created edited vacancy_attached vacancy_stage_changed comment_added vacancy_stage_changed_to_accepted vacancy_stage_changed_to_archived email_sent rated resume_edited candidate_edited]

  def self.vacancy_stage_groups_vortex(start_date, end_date)
    if start_date > end_date
      raise 'Start date has to be less than end date'
    end
    changes_ness = where(change_type: ['vacancy_stage_changed', 'vacancy_stage_changed_to_accepted', 'vacancy_stage_changed_to_archived'], timestamp: start_date..end_date)
    preload(changes_ness)
    cand_stage_array = []
    changes_ness.each do |cc|
      cand_stage_array << {candidate_id: cc.candidate_id, vacancy_stage_group: cc.change_for&.vacancy_stage_group&.id, vacancy: cc.vacancy&.id}
    end
    cand_stage_array.uniq!
    stage_hash = {}
    cand_stage_array.each do |cs|
      stage_hash[cs[:vacancy_stage_group]] ||= 0
      stage_hash[cs[:vacancy_stage_group]] += 1
    end
    stage_hash
  end

  private

  def self.preload(candidate_changes)
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(candidate_changes.select{|cc| cc.change_for_type.eql?(VacancyStage.name)}, {:vacancy => {}, change_for: :vacancy_stage_group})
  end
end