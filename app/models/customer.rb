class Customer < ApplicationRecord
  has_many :customer_projects
  has_many :projects, through: :customer_projects
  has_many :counterparties, dependent: :destroy
  has_many :non_responsible_counterparties, -> {where responsible: false}, class_name: 'Counterparty', dependent: :destroy
  has_one :responsible_counterparty, -> {where responsible: true}, class_name: 'Counterparty', dependent: :destroy
  has_many :customer_contacts, -> {order(name: :asc)}

  validates :name, presence: true
  validates_uniqueness_of :name
  validate :only_one_responsible_counterparty

  accepts_nested_attributes_for :counterparties, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :customer_contacts, reject_if: :all_blank, allow_destroy: true

  acts_as_tenant :company

  protected

  def only_one_responsible_counterparty
    matches = self.counterparties.to_a.select(&:responsible?)
    if matches.count > 1
      errors.add(:default, 'Только один контрагент может быть ответственным')
    end
  end
end
