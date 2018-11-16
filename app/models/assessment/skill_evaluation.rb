module Assessment
  class SkillEvaluation < ApplicationRecord
    self.table_name_prefix = 'assessment_'

    belongs_to :assessment_session_evaluation,
               class_name: 'Assessment::SessionEvaluation',
               foreign_key: :assessment_session_evaluation_id
    belongs_to :skill

    has_many :indicator_evaluations,
             class_name: 'Assessment::IndicatorEvaluation',
             dependent: :destroy,
             foreign_key: :assessment_skill_evaluation_id

    accepts_nested_attributes_for :indicator_evaluations, reject_if: :all_blank
  end
end
