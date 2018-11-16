module Admin::Resources::SurveysHelper
  def i18n_enum(enum, name_enum, hash = {})
    enum.keys.each { |key| hash[I18n.t("activerecord.enum.#{name_enum.to_s}.#{key}")] = key }
    hash
  end
end
