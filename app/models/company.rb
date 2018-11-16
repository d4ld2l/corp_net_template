class Company < ApplicationRecord
  has_many :accounts, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :legal_units, dependent: :destroy
  has_many :position_groups, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :vacancies, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :settings_groups, dependent: :destroy
  has_many :components, dependent: :destroy
  has_many :ui_settings, dependent: :destroy

  validates :name, presence: true

  def enabled_components
    Settings.enabled_components(id)
  end

  def component_enabled?(component_name)
    Settings.component_enabled?(id, component_name)
  end

  attr_accessor :seeds

  after_create do |company|
    company.seeds = []

    Dir[Rails.root.join('db/seeds/init_tetant', '*.rb')].sort.each do |file|
      require file
      seed_class_name = File.basename(file).split('_', 2).last[0..-4].camelize + 'CompanySeed'
      pp '='*20
      pp seed_class_name
      begin
        ActsAsTenant.without_tenant do
          seed_class_name.constantize.new(company).seed
        end
      rescue Exception => e
        company.destroy
        company.errors.add :seeds, e.message
        break
      end
    end
  end

  def self.default
    find_by(default: true) || first
  end

  def make_default
    transaction do
      Company.update_all(default: false)
      update(default: true)
    end
  end
end
