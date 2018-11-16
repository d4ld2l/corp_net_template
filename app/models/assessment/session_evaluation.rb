module Assessment
  class SessionEvaluation < ApplicationRecord
    self.table_name_prefix = 'assessment_'

    belongs_to :assessment_session,
               class_name: 'Assessment::Session',
               foreign_key: :assessment_session_id,
               touch: true
    belongs_to :account
    has_many :skill_evaluations,
             class_name: 'Assessment::SkillEvaluation',
             dependent: :destroy,
             foreign_key: :assessment_session_evaluation_id
    has_many :skills, through: :skill_evaluations
    has_many :indicators, through: :skills, class_name: 'Assessment::Indicator'

    accepts_nested_attributes_for :skill_evaluations, reject_if: :all_blank

    counter_culture :assessment_session,
                    column_name: 'evaluations_count'

    before_save :check_completeness

    private

    def check_completeness
      if assessment_session.skills_count != skill_evaluations.count
        self.done = true
      end
    end
  end
end
