module Assessment
  class ProjectRole < ApplicationRecord
    has_many :project_role_skills, class_name: 'Assessment::ProjectRoleSkill', dependent: :destroy
    has_many :skills, through: :project_role_skills, class_name: 'Skill'
    has_many :assessment_sessions, class_name: 'Assessment::Session', dependent: :nullify

    accepts_nested_attributes_for :project_role_skills, reject_if: :all_blank, allow_destroy: true

    acts_as_tenant :company

    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validate :skills_must_be_unique

    private

    def skills_must_be_unique
      s = project_role_skills.to_a.map(&:skill_id)
      if s.size - s.uniq.size > 0
        duplicate_ids = s.select{|x| s.count(x) > 1}.uniq
        errors.add(:skills, 'Компетенции должны быть уникальны') # Workaround
        project_role_skills.each{|x| x.errors.add(:skill_id, 'Компетенции должны быть уникальны') if duplicate_ids.include?(x.skill_id)}
      end
    end
  end
end
