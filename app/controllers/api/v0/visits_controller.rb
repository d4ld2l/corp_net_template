class Api::V0::VisitsController < Api::BaseController
  include ActionController::ImplicitRender
  respond_to :json
  layout false
  before_action :authenticate_account!

  def stats
    @total_visits = Account.includes(:ahoy_visits).where.not(ahoy_visits: { id: nil })
    @today_visits = Account.includes(:ahoy_visits).references(:ahoy_visits).where("ahoy_visits.started_at > ?", Date.today)
    render json: { status: true, stats: { total_active_users: @total_visits.count, today_active_users: @today_visits.count } }
  end
end
