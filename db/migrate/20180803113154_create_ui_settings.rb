class CreateUiSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :ui_settings do |t|
      t.references :company, foreign_key: true
      t.string :active_color, null: false
      t.string :active_color_light, null: false
      t.string :active_color_dark, null: false
      t.string :base_color, null: false
      t.string :menu_color, null: false
      t.string :main_logo
      t.string :signin_logo
      t.string :signin_animation
      t.string :main_page_picture

      t.timestamps
    end
  end
end
