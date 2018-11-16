class MigrateSkillConfirmationsToAccountSkills < ActiveRecord::Migration[5.2]
  def up
    Skill.where.not(account_id:nil).all.each do |s|
      as = AccountSkill.find_or_create_by(account_id:s.account_id, skill:s, project_id:s.project_id)
      SkillConfirmation.where(skill_id: s.id).update_all(account_skill_id:as.id)
    end
  end

  def down
    AccountSkill.all.each do |as|
      s = Skill.create(account_id:as.account_id, name: as&.skill&.name, project_id:as.project_id)
      SkillConfirmation.where(account_skill_id: as.id).update_all(skill_id:s.id)
    end
  end
end
