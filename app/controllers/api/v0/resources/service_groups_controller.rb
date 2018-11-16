class Api::V0::Resources::ServiceGroupsController < Api::ResourceController
  include Api::V0::Resources::ServiceGroups

  def association_chain
    super.where(services: { state: :published })
  end

end
