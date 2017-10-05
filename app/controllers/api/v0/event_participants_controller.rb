class Api::V0::EventParticipantsController < Api::BaseController
  include ActionController::ImplicitRender
  respond_to :json
  layout false

  def index
    @collection = []
    if params[:q]
      @collection = search_result(params[:q])
    end
    render :index
  end

  private

  def search_result(q)
    Searchkick.search(q, index_name:[User, Department], load: false, fields: search_fields, match: :word_start)
  end

  def search_fields
    [
        :name, :code, :full_name, :email, :name, :surname, :middlename, :email_private, :email_work,
        :email_corporate, :phone_private, :phone_work, :phone_corporate, :position_name
    ]
  end
end
