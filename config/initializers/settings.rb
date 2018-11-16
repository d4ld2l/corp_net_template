class Settings
  EXPIRED_IN = 90.minutes

  # modules

  def self.enabled_components(company_id)
    read_components(company_id).keep_if{|x| x['enabled']}
  end

  def self.component_enabled?(company_id, module_name)
    read_components(company_id).keep_if{|x| x['name'] == module_name.to_s}&.present?
  end

  def self.read_components(company_id)
    update_components if !read("#{company_id}/components") || read("#{company_id}/components")&.empty?
    read("#{company_id}/components")
  end

  def self.update_components
    Company.all.map do |c|
      update("#{c.id}/components", c.components.enabled.as_json)
    end
  end

  # common

  def self.read(key)
    Rails.cache.read(key)
  end

  def self.update(key, value)
    Rails.cache.write(key, value, expired_in: EXPIRED_IN)
  end
end