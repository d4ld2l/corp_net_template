module Paginatable
  extend ActiveSupport::Concern

  included do
    before_action :paginate, only: :index
  end

  def paginate
    @collection = @collection.page(params[:page]).per(30)
  end
end