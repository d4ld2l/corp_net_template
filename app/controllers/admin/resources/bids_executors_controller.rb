class Admin::Resources::BidsExecutorsController < Admin::ResourceController

  def index 
    @collection = @collection.includes(:account)
    super
  end 

end
