class Admin::ChatController < Admin::BaseController
  def index
    render 'index', layout: 'application-no-container'
  end
end
