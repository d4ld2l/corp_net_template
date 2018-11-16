class TokenAuth::SessionsController < DeviseTokenAuth::SessionsController
  skip_before_action :set_user_by_token, only:[:create]
  before_action :check_user_not_blocked, only: [:create]
  skip_before_action :set_tenant_by_current_account, only: [:create]
  skip_before_action :check_enabled
  before_action :set_tenant_by_host, only: [:create], if: ->{ AdminSetting.find_by(name: 'tenant_specific_auth')&.enabled? }

  def create
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys.keys).first

    @resource = nil
    if field
      q_value = resource_params[field]

      if resource_class.case_insensitive_keys.include?(field)
        q_value.downcase!
      end

      if field.in?([:login, :email])
        user = resource_class.where(["lower(login) LIKE ? OR lower(email) LIKE ?", q_value, q_value]).first
        @resource ||= user
      end
    end

    if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      valid_password = @resource.valid_password?(resource_params[:password])
      if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
        render_create_error_bad_credentials
        return
      end
      # create client id
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      @resource.skip_callbacks = true
      @resource.save(validate:false)

      sign_in(:account, @resource, store: false, bypass: false)

      yield @resource if block_given?

      render_create_success
    elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      render_create_error_not_confirmed
    else
      render_create_error_bad_credentials
    end
  end

  def render_create_success
    hash = {
      full_name: @resource.try(:full_name)
    }
    render json: {
      data: resource_data(resource_json: @resource.token_validation_response.merge(hash))
    }
  end

  def check_user_not_blocked
    if @resource&.blocked?
      respond_with json: {success: false, errors:['Аккаунт был заблокирован, обратитесь к администратору']}
    end
  end
end