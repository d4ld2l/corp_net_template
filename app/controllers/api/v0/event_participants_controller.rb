class Api::V0::EventParticipantsController < Api::BaseController
  respond_to :json
  layout false
  before_action :authenticate_account!

  def index
    @collection = []
    if params[:q]
      @collection = search_result(params[:q])
    end
    render json: jsonize(@collection)
  end

  private

  def search_result(q)
    query = {
      query: {
        multi_match: {
          query: q,
          fields: %w[name^30 surname middlename code phone email_address position_name full_name],
          type: 'phrase_prefix',
          operator: 'and'
        }
      },
      size: 100
    }
    Elasticsearch::Model.search(query, [MailingList, Account, Department]).records.to_a
  end

  def jsonize(collection)
    EventParticipantsPreloader.preload(collection)
    collection.map do |x|
      case x.class.name
      when 'Account'
        x.as_json(only: %i[id photo], methods: %i[email_address position_name full_name model_name])
      when 'MailingList'
        x.as_json(only: %i[id name], methods: %i[accounts_count model_name], include: {accounts: {only: %i[id photo], methods: %i[email_address position_name full_name]}})
      when 'Department'
        x.as_json(only: %i[id name logo], methods: %i[employees_count model_name], include: {accounts: {only: %i[id photo], methods: %i[email_address position_name full_name]}})
      end
    end
  end
end
