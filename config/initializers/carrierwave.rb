CarrierWave.configure do |config|
  config.root = "#{ENV['HOME']}/" if Rails.env.production?
  config.permissions = 0664
  config.directory_permissions = 0777
  config.storage = :file
  config.enable_processing = false if Rails.env.test?
end
