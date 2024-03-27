# frozen_string_literal: true

# Provides helpers making specs for various controller responses easier to
# write.
module ResponseHelpers
  def succeeds
    expect(response).to have_http_status(:ok)
  end

  def redirects
    expect(response).to have_http_status(:redirect)
  end

  def redirects_to(path)
    expect(response).to redirect_to(path)
  end
end

RSpec.configure do |_config|
  include ResponseHelpers
end
