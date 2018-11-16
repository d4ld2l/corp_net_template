class ProfileProject < ApplicationRecord
	include AASM
	# include Elasticsearch::Model
	# include Indexable

	belongs_to :profile
	belongs_to :project, counter_cache: true, optional: true, touch: true
  has_many :project_work_periods

	accepts_nested_attributes_for :project_work_periods, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :profile, reject_if: :all_blank, update_only: true

	scope :only_active, ->{where(status: 'active')}
	scope :only_gone, ->{where(status: 'gone')}

	validates :rating, numericality: { greater_than: -1, less_than_or_equal_to: 5 }, if: ->{rating}
	validates :worked_hours, numericality: {greater_than_or_equal_to: 0}, if: -> {worked_hours}
	validates_presence_of :profile_id
	validates_uniqueness_of :profile_id, scope: :project_id

	aasm column: :status do
		state :active, initial: true
		state :gone

		event :to_active, before: :revert_gone_date do
			transitions from: %i[gone], to: :active
		end

		event :to_gone, before: :revert_gone_date do
			transitions from: %i[active], to: :gone
		end
	end

	# def as_indexed_json(options = {})
	# 	as_json(include: {profile:{methods:[:full_name]}, project_work_periods:{}})
	# end

	private

	def revert_gone_date
		self.gone_date = self.gone? ? nil : Date.today
	end
end
