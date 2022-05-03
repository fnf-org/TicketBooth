# frozen_string_literal: true

require 'csv'

module FnF
  class CSVReader
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def read(skip_first: true, before_block: nil, after_block: nil, &_block)
      File.open(path) do |file|
        first_line = true
        before_block[] if before_block
        CSV.foreach(file) do |row|
          if skip_first && first_line
            first_line = false
            next
          end

          # split by three rows
          dj_name, real_name, url = *row
          real_name = real_name.split(/ /).map(&:capitalize).join(' ')
          yield(dj_name, real_name, url) if block_given?
        end
        after_block[] if after_block
      end
    end
  end
end
