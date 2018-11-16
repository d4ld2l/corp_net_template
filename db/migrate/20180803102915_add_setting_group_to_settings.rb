class AddSettingGroupToSettings < ActiveRecord::Migration[5.2]
  def change
    add_reference :settings, :settings_group, index: true
  end
end
