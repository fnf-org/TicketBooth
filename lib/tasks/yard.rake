# frozen_string_literal: true

require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w[{app,config,lib}/**/*.rb - README.adoc DEVELOPERS.adoc CHANGELOG.md LICENSE]
  t.options.unshift('--title', '"Ticket Booth for the Communities"')
  t.after = lambda {
    system('/usr/bin/env bash -c "sleep 3; [[ -f doc/index.html ]] && open doc/index.html" & ')
  }
end
