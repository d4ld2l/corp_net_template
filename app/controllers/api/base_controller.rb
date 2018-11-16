class Api::BaseController < ApplicationController
  respond_to :json
  include DeviseTokenAuth::Concerns::SetUserByToken
  # before_action :check_format
  before_action :check_account_not_blocked

  def catch_404
    raise ActionController::RoutingError, params[:path]
  end

  # TODO: make var that allows do not catch this
  rescue_from ::Exception do |e|
    render json: { success: false, error: 'Все совсем плохо, не трогайте здесь ничего больше', error_type: e.class.name }.merge(get_backtrace_hash(e)), status: 500
  end

  rescue_from ::RuntimeError do |e|
    render json: { success: false, error: 'Что-то сломалось. Не надо так больше делать.', error_type: e.class.name }.merge(get_backtrace_hash(e)), status: 500
  end

  rescue_from ::TypeError do |e|
    render json: { success: false, error: 'Вы сломали код. Это не по-товарищески.', error_type: e.class.name }.merge(get_backtrace_hash(e)), status: 500
  end

  def check_format
    render nothing: true, status: 406 unless params[:format] == 'json' || request.headers['Accept'] =~ /json/
  end

  rescue_from ActionController::RoutingError do |e|
    render json: { success: false, error: 'Метод не поддерживается' }.merge(get_backtrace_hash(e)), status: 405
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { success: false, error: 'Запись не найдена' }.merge(get_backtrace_hash(e)), status: 404
  end

  rescue_from ActionController::ParameterMissing do
    render json: { success: false, error: 'Неверный запрос' }.merge(get_backtrace_hash(e)), status: 400
  end

  rescue_from ActsAsTenant::Errors::NoTenantSet do |e|
    render json: { success: false, error: 'Тенант не определен' }.merge(get_backtrace_hash(e)), status: 400
  end

  def check_account_not_blocked
    render json: { success: false, errors: ['Аккаунт был заблокирован, обратитесь к администратору'] }, status: 401 if current_account&.blocked?
  end

  private

  def get_backtrace_hash(e)
    if ENV['SHOW_FULL_TRACE'] == 'true'
      { error_backtrace: [e.class.name] + e.backtrace }
    else
      {}
    end
  end
end
