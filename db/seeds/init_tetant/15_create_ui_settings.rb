class CreateUiSettingsCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    ui = UiSetting.where(company_id: @company.id).first_or_initialize
    ui.company_id = @company.id unless ui.company_id
    ui.update(
        active_color: '#ff2f51',
        active_color_light: '#ff7b91',
        active_color_dark: '#CE223D',
        base_color: '#575b97',
        menu_color: '#2b2d4b',
        head_menu_item_active: '#ffdb36',
        head_menu_item_hover: '#a78de5',
        head_menu_item: '#ffffff',
        side_menu_color: '',
        main_logo: nil,
        signin_logo: File.open('app/assets/images/default_ui_settings/logo-form.png'),
        signin_animation: File.open('app/assets/images/default_ui_settings/login-loader.gif'),
        main_page_picture: nil
    )
  end
end
