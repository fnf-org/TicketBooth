# frozen_string_literal: true

# Provides helpers making specs for various controller responses easier to
# write.
module ResponseHelpers
  def succeeds
    response.status.should eq 200
  end

  def redirects
    response.should be_redirect
  end

  def redirects_to(path)
    response.should redirect_to(path)
  end
end

RSpec.configure do |_config|
  include ResponseHelpers
end
