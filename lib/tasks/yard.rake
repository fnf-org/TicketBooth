# frozen_string_literal: true

require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w[app/**/*.rb lib/**/*.rb - README.adoc DEVELOPERS.adoc LICENSE]
  t.options.unshift('--title', '"FnF Ticketing App"')
  t.after = lambda {
    system('open doc/index.html')
  }
end
