class NewsCategory < ApplicationRecord
  has_many :news_items
  validates_presence_of :name
end
