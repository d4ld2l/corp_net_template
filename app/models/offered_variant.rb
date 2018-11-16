class OfferedVariant < ApplicationRecord
  belongs_to :question
  has_many :survey_answers, through: :question

  acts_as_list scope: :question

  mount_uploader :image, ImageSurveyUploader
  mount_base64_uploader :image, ImageSurveyUploader

  def users_count
    survey_answers.map(&:answers).map {|ans| ans.select {|id, val| id.to_i == self.id.to_i && val == true}}.select(&:any?).count
  end

  def users_percentage
    return 0 if survey_answers.blank?
    users_count.to_f / survey_answers.count * 100.0
  end
end
