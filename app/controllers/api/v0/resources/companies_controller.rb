class Api::V0::Resources::CompaniesController < Api::ResourceController
  before_action :authenticate_account!

  private

  def permitted_attributes
    [:name]
  end
end
