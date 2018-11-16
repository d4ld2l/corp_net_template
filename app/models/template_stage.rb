class TemplateStage < ApplicationRecord
  has_many :vacancy_stages, ->{order(:position)}

  accepts_nested_attributes_for :vacancy_stages, reject_if: :all_blank, allow_destroy: true

  acts_as_tenant :company
end
