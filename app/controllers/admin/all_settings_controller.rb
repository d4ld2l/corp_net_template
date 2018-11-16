class Admin::AllSettingsController < Admin::BaseController

  def index
    @common = Setting.all
    @common_groups = SettingsGroup.includes(:settings)
    @ui = UiSetting.first
  end

end
