# Provides helpers making specs for various controller responses easier to
# write.
module ResponseHelpers
  def succeeds
    response.should be_success
  end

  def redirects
    response.should be_redirect
  end

  def redirects_to(path)
    response.should redirect_to(path)
  end
end

RSpec.configure do |config|
  include ResponseHelpers
end
