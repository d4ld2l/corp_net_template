class AddDescriptionAndCompanyIdToSkills < ActiveRecord::Migration[5.2]
  def change
    add_column :skills, :description, :string
    add_reference :skills, :company, index: true
  end
end
