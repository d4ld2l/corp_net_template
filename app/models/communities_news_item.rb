class CommunitiesNewsItem < ApplicationRecord
  belongs_to :community
  belongs_to :news_item
end
