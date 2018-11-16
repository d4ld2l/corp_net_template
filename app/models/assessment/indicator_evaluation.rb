module Assessment
  class IndicatorEvaluation < ApplicationRecord
    self.table_name_prefix = 'assessment_'

    belongs_to :assessment_skill_evaluation,
               class_name: 'Assessment::SkillEvaluation',
               foreign_key: :assessment_skill_evaluation_id

    belongs_to :assessment_indicator,
               class_name: 'Assessment::Indicator',
               foreign_key: :indicator_id

    enum rating_scale: %i[ six ]
  end
end
