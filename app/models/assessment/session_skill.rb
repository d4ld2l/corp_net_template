class Assessment::SessionSkill < ApplicationRecord
  self.table_name_prefix = 'assessment_'

  belongs_to :session, class_name: 'Assessment::Session', foreign_key: 'assessment_session_id'
  belongs_to :skill, class_name: 'Skill'

  validates_uniqueness_of :skill_id, scope: [:assessment_session_id]

  counter_culture :session, column_name: 'skills_count'

  acts_as_list scope: :assessment_session
end
