class Api::V0::LoginSettingsController < Api::BaseController
  skip_before_action :check_account_not_blocked
  skip_before_action :check_enabled
  skip_before_action :set_tenant_by_current_account

  def index
    host = params[:host] || request.headers["X-Reactor-Host"]
    # delete schema & path
    if host
      if stripped_host = URI.parse(host).host
        host = stripped_host
      end

      # split into domain & subdomain
      splitted_host = host.split('.')
      domain = splitted_host[1..-1].join('.')
      subdomain = splitted_host[0]

      #set company & tenant
      company = Company.find_by(subdomain: subdomain, domain: domain)
      company = Company.find_by(subdomain: subdomain) unless company
    end
    company = Company.default unless company
    @settings = company&.present? ? UiSetting.find_by(company_id:company&.id) : nil
    render json: @settings&.as_json(
        except:[:id, :company_id, :created_at, :updated_at, :main_logo, :signin_logo, :signin_animation, :main_page_picture, :signin_picture],
        methods:[:main_logo_url, :signin_logo_url, :signin_animation_url, :main_page_picture_url, :signin_picture_url]
    ) || {}
  end
end
