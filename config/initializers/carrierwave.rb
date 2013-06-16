CarrierWave.configure do |config|
  config.permissions = 0664
  config.directory_permissions = 0777
  config.storage = :file
  config.enable_processing = false if Rails.env.test?
end

# Convenience method for specifying quality of images in uploaders
module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
