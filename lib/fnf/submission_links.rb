# frozen_string_literal: true

require_relative 'html_generator'
require_relative 'csv_reader'
require 'active_support'

# rubocop: disable Rails/Exit
module FnF
  class SubmissionLinks
    attr_reader :csv_file, :output_stream, :generator, :reader

    def initialize(csv, html = nil, simple_css: false)
      if csv.nil? || !File.exist?(csv)
        warn "USAGE: #{$PROGRAM_NAME} csv-file [ --simple-css ] "
        warn '       Where the CSV file has three columns: DJ Name, Real Name, URL'
        warn '       If you pass --simple-css you will also get the <head> with simple CSS included'
        exit(1)
      end

      @csv_file = csv.is_a?(File) ? csv.path : csv

      @output_stream = if html
                         File.open(html, 'w')
                       else
                         $stdout
                       end

      @generator = FnF::HTMLGenerator.new(simple_css:)
      @reader = FnF::CSVReader.new(csv_file)
    end

    def run
      reader = @reader
      result = generator.generate(:html) do
        reader.read do |dj_name, real_name, url|
          li do
            strong { a(href: url, target: '_blank', ref: 'canonical') { dj_name } }
            if dj_name == real_name
              self
            else
              span class: 'djName' do
                "(#{real_name.split(/ /).map(&:capitalize).join(' ')})"
              end
            end
          end
        end
      end

      output_stream.write(result)
      output_stream.close if output_stream != $stdout
      result
    end
  end
end
# rubocop: enable Rails/Exit
