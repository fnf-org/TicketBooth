# frozen_string_literal: true

require 'stringio'
require 'active_support'
require 'active_support/core_ext/object/blank'

# rubocop: disable Rails/Output

# @description
# How this works: The HtmlGenerator is a StringIO subclass which means that any print/puts inside the class
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
module FnF
  class HtmlGenerator < StringIO
    attr_accessor :level
    attr_reader :indent, :simple_css

    def initialize(*args, simple_css: false, &)
      super
      @level      = 0
      @indent     = 2
      @simple_css = simple_css
    end

    def simple_css_header
      return unless simple_css

      header = <<~HTML
        <head>
          <!-- Minified version -->
          <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
        </head>
      HTML

      header.gsub(/^/, ' ' * level * indent)
    end

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
      options        = opts.map { |k, v| %(#{k}="#{v}" ) }
      html_arguments = ''
      html_arguments += " #{args.join(' ')}" unless args.empty?
      html_arguments += " #{options.join(' ')}" unless options.empty?

      indent_element do
        print "<#{method}"
        print ' ' if html_arguments.present?
        print html_arguments.strip

        if block
          print ">\n"

          result = instance_exec(*block.parameters, &block)
          if result.present? && result != self
            indent_element do
              puts result
            end
          end

          print_element "</#{method}>"
        else
          puts '/>'
        end
      end

      self
    end

    HTML_ELEMENTS.each do |element|
      define_method(element) { |*args, **opts, &block| html_element(element, *args, **opts, &block) }
    end

    def render(stream = $stdout, &)
      stream.puts(generate(&))
    end

    def generate(*args, **, &block)
      return unless block

      element = args.shift unless args&.empty?
      if element
        puts "<#{element}>"
        self.level += 1
      end

      puts simple_css_header if simple_css_header

      self.level = element ? 0 : -1

      instance_exec(*args, &block) if block_given?

      puts "</#{element}>" if element

      string
    end

    private

    def print_element(element)
      print(' ' * level * indent).to_s
      puts element
    end

    def indent_element
      self.level += 1
      print(' ' * level * indent).to_s
      yield(self) if block_given?
      self.level -= 1
    end
  end
end

# rubocop: enable Rails/Output
