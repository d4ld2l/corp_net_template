class ChangeSettingsGroups < ActiveRecord::Migration[5.2]
  def change
    rename_column :settings_groups, :name, :label
    add_column :settings_groups, :code, :string, null: false
    add_reference :settings_groups, :company, foreign_key: true
  end
end
