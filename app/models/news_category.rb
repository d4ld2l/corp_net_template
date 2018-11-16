class NewsCategory < ApplicationRecord
  has_many :news_items, dependent: :destroy
  validates_presence_of :name

  acts_as_tenant :company
end
