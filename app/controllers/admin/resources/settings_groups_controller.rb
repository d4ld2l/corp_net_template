class Admin::Resources::SettingsGroupsController < Admin::ResourceController

  def show
    redirect_to settings_groups_path
  end

  def new
    redirect_to settings_groups_path, alert: 'Нельзя создать группу настроек'
  end

  def permitted_attributes
    [:id, :label]
  end
end
