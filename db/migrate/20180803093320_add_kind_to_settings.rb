class AddKindToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :kind, :integer, default: 0, null: false
  end
end
