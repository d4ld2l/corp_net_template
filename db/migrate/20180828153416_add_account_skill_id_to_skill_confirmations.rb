class AddAccountSkillIdToSkillConfirmations < ActiveRecord::Migration[5.2]
  def change
    add_reference :skill_confirmations, :account_skill, index: true
  end
end
