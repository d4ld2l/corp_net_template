module Admin::Resources::SettingsHelper
  def pretty_value(kind ,value)
    res = content_tag :span do
      value
    end
    if kind.to_sym == :color
      res += content_tag(:i, class:'fa fa-circle', style: "color: #{value}"){}
    end
    res
  end
end
