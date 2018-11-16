class UiSettingsUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "#{relative_path}uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    nil
  end

  process resize_to_limit: [1000, 1000]

  def extension_whitelist
    %w(jpg jpeg gif png svg)
  end
end
