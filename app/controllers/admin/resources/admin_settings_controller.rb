class Admin::Resources::AdminSettingsController < Admin::ResourceController
  def index
  end

  def show
    redirect_to admin_settings_path
  end

  def edit
  end

  def permitted_attributes
    [:value]
  end
end
