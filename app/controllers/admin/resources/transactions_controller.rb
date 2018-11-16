class Admin::Resources::TransactionsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :kind, :value, :recipient_id, :profile_achievement_id, :comment]
  end
end
