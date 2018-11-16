class Admin::Resources::SettingsController < Admin::ResourceController

  def index
    redirect_to all_settings_path
  end

  def show
    redirect_to settings_path
  end

  def new
    redirect_to settings_path, alert: 'Нельзя создать настройку'
  end

  def permitted_attributes
    [:id, :label, :value]
  end
end
