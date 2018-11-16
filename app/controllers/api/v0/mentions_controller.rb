class Api::V0::MentionsController < Api::BaseController
  include ActionController::ImplicitRender
  respond_to :json
  layout false
  before_action :authenticate_account!

  def index
    return( render json: {success: false, errors:['Необходимо передать запрос для поиска (параметр q)']} ) unless params[:q]
    return( render json: {success: false, errors:['Длина поискового запроса (параметр q) должна быть не меньше 2']} ) if params[:q]&.to_s&.length < 2
    return( render json: search.as_json(methods: %i[full_name email]) )
  end

  private

  def search
    query = params[:q]&.dup.to_s[0..127]
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)

    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end

    Account.search("#{query}", fields: %i[full_name login], match: :word_start, body_options: {min_score: 1})
  end
end
