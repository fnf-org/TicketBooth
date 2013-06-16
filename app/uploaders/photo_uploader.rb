class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type

  # Prevent enormous photos from being stored
  process resize_to_limit: [1000, 1000]

  version :jumbo do
    process resize_to_limit: [640, 480]
  end

  version :thumb do
    process resize_to_fill: [50, 50]
  end

  # Directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Directory where uploaded files are stored temporarily until model is saved,
  # at which point they are moved to the final storage directory.
  def cache_dir
    '/tmp/uploads'
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  # Randomly generate filename for uploaded photos.
  # This prevents someone from guessing the URL of another event's photos.
  def filename
    extension = file.extension == 'jpeg' ? 'jpg' : file.extension
    "#{secure_token(10)}.#{extension}"
  end

protected

  def secure_token(length = 16)
    ivar = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(ivar) or
      model.instance_variable_set(ivar, SecureRandom.hex(length / 2))
  end
end
