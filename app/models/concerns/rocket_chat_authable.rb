module RocketChatAuthable
  extend ActiveSupport::Concern
  require 'net/http'

  included do
    def rocket_chat_authorized?(token, client_id)
      url = ENV['ROCKETCHAT_API_URL']+'/me'
      uri = URI.parse(url)
      httpcall = Net::HTTP.new(uri.host, uri.port)
      response = httpcall.get2(uri.path, {'X-Auth-Token': token, 'X-User-Id': client_id})
      JSON.parse(response.body)['status'] != 'error'
    end

    def rocket_chat_authorize(username, password)
      params = {'email': username, 'password': password}
      response = JSON.parse(Net::HTTP.post_form(URI.parse(ENV['ROCKETCHAT_API_URL']+'/login'), params).body)
      if response['status'] != 'error'
         {token: response['data']['authToken'], client_id: response['data']['userId']}
      else
        nil
      end
    end
  end
end
