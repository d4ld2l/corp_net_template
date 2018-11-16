class Discusser < ApplicationRecord
  belongs_to :account
  belongs_to :discussion
end
