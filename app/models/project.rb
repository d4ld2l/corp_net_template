class Project < ApplicationRecord
	has_many :user_projects, dependent: :destroy
	has_many :users, through: :user_projects
	belongs_to :customer
	belongs_to :legal_unit

	accepts_nested_attributes_for :user_projects, allow_destroy: true

	validates :title, presence: true
end
