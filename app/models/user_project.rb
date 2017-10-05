class UserProject < ApplicationRecord
	belongs_to :user
	belongs_to :project
	belongs_to :project_role

	validates :rating, numericality: { greater_than: 0, less_than_or_equal_to: 5 }, if: ->{rating}
end
