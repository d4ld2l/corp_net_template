class Admin::HomeController < Admin::BaseController
  def index
    @communities = Community.last(5)
    @news = NewsItem.only_published.last(5)
  end
end
