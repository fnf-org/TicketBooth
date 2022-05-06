# frozen_string_literal: true

require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  system("bash -c 'sleep 5 && open doc/index.html' &")
  t.files = %w[app/**/*.rb lib/**/*.rb - README.adoc DEVELOPERS.adoc LICENSE]
  t.options.unshift('--title', '"FnF Ticketing App"')
end
