class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type

  # Prevent enormous photos from being stored
  process resize_to_limit: [1000, 1000]

  version :jumbo do
    process resize_to_limit: [640, 480]
    process quality: 65
  end

  version :thumb do
    process resize_to_fill: [50, 50]
    process quality: 50
  end

  # Directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Directory where uploaded files are stored temporarily until model is saved,
  # at which point they are moved to the final storage directory.
  def cache_dir
    "uploads/cache/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  # Randomly generate filename for uploaded photos.
  # This prevents someone from guessing the URL of another event's photos.
  def filename
    return unless file
    if model.send("#{mounted_as}_changed?")
      # Generate a secure name for the new file
      extension = file.extension == 'jpeg' ? 'jpg' : file.extension
      "#{secure_token}.#{extension}"
    else
      super
    end
  end

protected

  def secure_token(length = 16)
    ivar = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(ivar) or
      model.instance_variable_set(ivar, SecureRandom.hex(length / 2))
  end
end
