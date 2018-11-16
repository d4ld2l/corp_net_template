class AddColorsToUiSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :ui_settings, :side_menu_color, :string, default: '', null: false
    add_column :ui_settings, :head_menu_item, :string, default: '', null: false
    add_column :ui_settings, :head_menu_item_active, :string, default: '', null: false
    add_column :ui_settings, :head_menu_item_hover, :string, default: '', null: false
  end
end
