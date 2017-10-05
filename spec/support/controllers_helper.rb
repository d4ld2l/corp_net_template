module ControllersHelper
  include Warden::Test::Helpers

  def auth(user)
    user.skip_confirmation!
    user.save!

    @auth_token = user.create_new_auth_token
    @resource_client_id = @auth_token['client']

    age_token user, @resource_client_id
    login_as(user, scope: :user)
    @auth_token
  end

  def age_token(user, client_id)
    if user.tokens[client_id]
      user.tokens[client_id]['updated_at'] = Time.now - (DeviseTokenAuth.batch_request_buffer_throttle + 10.seconds)
      user.save!
    end
  end
end