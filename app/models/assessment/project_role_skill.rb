module Assessment
  class ProjectRoleSkill < ApplicationRecord
    belongs_to :skill, class_name: 'Skill'
    belongs_to :project_role, class_name: 'Assessment::ProjectRole'

    acts_as_tenant :company
    counter_culture [ :project_role ], column_name: 'skills_count'
  end
end
