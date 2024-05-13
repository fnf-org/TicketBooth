# frozen_string_literal: true

module Routing
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  class << self
    def routes
      Rails.application.routes.url_helpers
    end
  end
end
