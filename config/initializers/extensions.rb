# frozen_string_literal: true

Dir.glob("#{Rails.root}/lib/extensions/*").sort.each { |f| require f }
