# Модули системы
class Component < ApplicationRecord
  belongs_to :company
  belongs_to :core_component, class_name: 'Component'
  has_many :children, class_name: 'Component', foreign_key: :core_component_id

  acts_as_tenant :company

  scope :core, -> { where(core_component_id: nil) }
  scope :enabled, -> { where(enabled: true) }

  validates_presence_of :name, :company_id

  after_save :update_cached_settings
  after_update :disable_child_modules, if: -> { core? }
  after_update :enable_core_component, unless: -> { core? }

  def update_cached_settings
    Settings.update("#{company_id}/components", Component.enabled.as_json)
  end

  def as_json(options = {})
    super(only: %i[id name core_component_name enabled])
  end

  def core_component_name
    core_component&.name
  end

  def toggle
    update(enabled: !enabled)
  end

  def core?
    core_component_id.nil?
  end

  private

  def disable_child_modules
    children.update_all(enabled: false) unless enabled?
  end

  def enable_core_component
    core_component.update(enabled: true) if enabled?
  end
end
