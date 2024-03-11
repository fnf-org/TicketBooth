# frozen_string_literal: true

Dir.glob(Rails.root.join('lib/extensions/*').to_s).each { |f| require f }
