class CarrierWave::Uploader::Base
  def base_path
  end

  def relative_path
    if (relative_url_root = Rails.application.config.relative_url_root).present?
      relative_url_root.sub(/\A\//, '') + '/'
    else
      ''
    end
  end
end
