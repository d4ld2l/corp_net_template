class Question < ApplicationRecord
  belongs_to :survey, touch: true
  has_many :offered_variants, dependent: :destroy
  has_many :survey_answers, dependent: :destroy
  acts_as_list scope: :survey

  enum question_type: %w[single multiple]

  accepts_nested_attributes_for :offered_variants, reject_if: :all_blank, allow_destroy: true

  before_save :set_ban, if: -> {survey.complex?}

  mount_uploader :image, ImageSurveyUploader
  mount_base64_uploader :image, ImageSurveyUploader

  validates :position, presence: true
  with_options if: :ban_own_answer? do
    validates :offered_variants, length: {in: 1..100, message: 'Количество вариантов должно быть в диапазоне от 1 до 100'}
  end
  with_options unless: :ban_own_answer? do
    validates :offered_variants, length: {in: 0..100, message: 'Количество вариантов должно быть в диапазоне от 0 до 100'}
  end

  # validates_absence_of :question_type, if: -> {survey.survey_type == 'complex'}
  # validates_presence_of :question_type, if: -> {survey.survey_type == 'simple'}

  def own_answer_count
    return 0 if ban_own_answer?
    survey_answers&.map(&:answers)&.map {|ans| ans.select {|id, val| id == 'own_answer' && !val.blank?}}&.select(&:any?)&.count
  end

  def own_answer_percentage
    return 0 if survey_answers.blank?
    (own_answer_count&.to_f / survey_answers&.count * 100.0)
  end

  private

  def set_ban
    self.ban_own_answer = true
  end
end
