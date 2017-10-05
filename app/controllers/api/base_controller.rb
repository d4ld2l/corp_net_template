class Api::BaseController < ApplicationController
  respond_to :json
  include DeviseTokenAuth::Concerns::SetUserByToken
  #before_action :check_format


  def check_format
    render :nothing => true, :status => 406 unless params[:format] == 'json' || request.headers["Accept"] =~ /json/
  end
end
