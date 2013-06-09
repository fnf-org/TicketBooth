# Don't log static-asset-related info, as it just adds noise.
if Rails.env.development?
  Rails.application.assets.logger = Logger.new('/dev/null')
end
