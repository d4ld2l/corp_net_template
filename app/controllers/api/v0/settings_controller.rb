class Api::V0::SettingsController < Api::BaseController
  before_action :authenticate_account!

  def index
    @ui = UiSetting.first.as_json(
        except: [:id, :company_id, :created_at, :updated_at, :main_logo, :signin_logo, :signin_animation, :main_page_picture, :signin_picture],
        methods: [:main_logo_url, :signin_logo_url, :signin_animation_url, :main_page_picture_url, :signin_picture_url]
    ) || nil
    @components = Component.all.map { |x| { "#{x.name}": x.enabled } }.reduce(&:merge).as_json
    @common = SettingsGroup.includes(:settings).map do |x|
      {
        "#{x.code}": x.settings.map do |y|
          { "#{y.code}": y.as_json(
            only: %i[label kind value]
          ) }
        end.reduce(&:merge)
      }
    end.reduce(&:merge) || {}

    @result = {
      settings: {
        ui: @ui,
        enabled_components: @components
      }.merge(@common)
    }
    render json: @result
  end
end
