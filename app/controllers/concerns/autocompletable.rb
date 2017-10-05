module Autocompletable
  extend ActiveSupport::Concern
  
  included do
    def autocomplete
      render json: association_chain.search(params[:q], page: params[:page], per_page: 20, limit: 10)
                    .map { |resource| resource.as_json(only: [:id, :name])&.merge(photo: resource&.photo&.thumb) }
    end
  end
end
