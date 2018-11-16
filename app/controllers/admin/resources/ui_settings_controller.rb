class Admin::Resources::UiSettingsController < Admin::ResourceController

  def index
    redirect_to edit_ui_setting_path(UiSetting.first)
  end

  def show
    redirect_to edit_ui_setting_path(UiSetting.first)
  end

  def new
    redirect_to edit_ui_setting_path, alert: 'Нельзя создать настройку'
  end

  def permitted_attributes
    [
        :id, :active_color, :active_color_light, :active_color_dark, :base_color,
        :menu_color, :main_logo, :signin_logo, :signin_animation, :main_page_picture, :signin_picture, :side_menu_color,
        :head_menu_item, :head_menu_item_active, :head_menu_item_hover
    ]
  end
end
