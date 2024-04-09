# frozen_string_literal: true

require 'stringio'

module FnF
  # @description
  # How this works: The HTMLGenerator is a StringIO subclass which means that any print/puts inside the class
  # simply appends to the string representation. We convert method_missing into HTML elements so you can call
  #
  # @example
  #   span do
  #     p do
  #       a href: url do
  #         "and so on"
  #       end
  #     end
  #   end
  class HTMLGenerator < StringIO
    HTML_ELEMENTS = %w[
      html link meta style a ol ul li
      strong em div span p body head script
      h1 h2 h3 h4 title footer header
      dd dt dv blockquote br code pre
      cite abbr address area video audio embed
    ].freeze

    # @param [Symbol] method name of the HTML element
    # @param [Array] args arguments, only supported argument is :br indicating newline after the element
    # @param [Hash{Symbol->Unknown}] attributes of the HTML element, eg: href: url
    # @param [Proc] block optional block for the contents of the tag
    def html_element(method, *args, **opts, &block)
      options = opts.map { |k, v| %( #{k}="#{v}" ) }.join
      options = " #{options}" if options
      self.print "<#{method}#{options}" if options
      process_block(block, method)
      Rails.logger.debug if args.include?(:br)
    end

    HTML_ELEMENTS.each do |element|
      define_method(element) { |*args, **opts, &block| html_element(element, *args, **opts, &block) }
    end

    def render
      $stdout.puts(string)
    end

    def generate(&)
      instance_exec(&)
    end

    private

    def process_block(block, method)
      if block
        Rails.logger.debug '>'
        result = instance_exec(&block)
        Rails.logger.debug result unless result.nil?
        Rails.logger.debug { "</#{method}>" }
      else
        Rails.logger.debug '/>'
      end
    end
  end
end
