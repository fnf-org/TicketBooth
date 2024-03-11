# frozen_string_literal: true

require 'factory_bot'

# Convenience methods added to invoke FactoryBot factories by sending
# messages directly to ActiveRecord classes.
#
# We use these rather than the one provided by FactoryBot itself
# (factory_bot/syntax/make) because we want wrappers for all four methods,
# not just "create", and we also want the option of customising the returned
# instance via a block.
module ActiveRecord
  class Base
    class << self
      # Wrapper for FactoryBot.build
      def make(...)
        make_with(name.underscore, ...)
      end

      # Like #make, but allows the caller to explicitly specify a factory name.
      def make_with(factory_name, ...)
        factory_bot_delegate(:build, factory_name, ...)
      end

      # Wrapper for FactoryBot.build_list
      def make_list(count, ...)
        factory_bot_delegate(:build_list, name.underscore, count, ...)
      end

      # Wrapper for FactoryBot.create
      def make!(...)
        make_with!(name.underscore, ...)
      end

      # Like #make!, but allows the caller to explicitly specify a factory name.
      def make_with!(factory_name, ...)
        factory_bot_delegate(:create, factory_name, ...)
      end

      # Wrapper for FactoryBot.build_list
      def make_list!(count, ...)
        factory_bot_delegate(:create_list, name.underscore, count, ...)
      end

      # Wrapper for FactoryBot.attributes_for
      def valid_attributes(...)
        valid_attributes_with(name.underscore, ...)
      end

      # Like #valid_attributes, but allows the caller to explicitly specify a
      # factory name.
      def valid_attributes_with(factory_name, ...)
        factory_bot_delegate(:attributes_for, factory_name, ...)
      end

      private

      def factory_bot_delegate(method, factory_name, *)
        object = FactoryBot.__send__(method, factory_name, *)
        yield object if block_given?
        object
      end
    end
  end
end

# Shams were a feature of Factory Bot until version 4.0. This is a thin wrapper
# that allows us to continue using Shams (as they're very simple).
module Sham
  def self.method_missing(method, *args, &block)
    raise ArgumentError, "Sham.#{method} called with #{args.inspect}" if args.any?

    if block_given? # defining a Sham
      FactoryBot.define do
        sequence method, &block
      end
    else # using a Sham
      FactoryBot.generate method
    end
  end
end

def Sham.email_address
  "#{Sham.string(12)}@#{Sham.string(10)}.com"
end

Sham.positive_integer { |n| n }

Sham.street_address do |n|
  "#{n} #{Sham.words(2)} Street"
end

# Produce a zip code, starting at 10,000.
Sham.zip_code do |n|
  format('%.5d', (n + 10_000))
end

# Generate a random string of length k.
def Sham.string(k)
  chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  1.upto(k).reduce('') { |string, _| string + chars[rand(chars.size - 1)] }
end

# Generate a random but prounounceable word.
# Modified from: http://snipplr.com/view.php?codeview&id=1247
def Sham.word(n = [2, 4, 6].sample)
  c = %w[b c d f g h j k l m n p qu r s t v w x z] +
      %w[ch cr fr ph pr sh sl sp st th tr]
  v = %w[a e i o u y]
  e = %w[ch nd ng nk nt ph rd sh sp st]
  suf = rand > 0.5 ? e.sample : ''
  f = false
  (0...n).map { (f = !f) ? c.sample : v.sample }.join + suf
end

# Generate a sentence of n random but pronounceable words.
def Sham.words(n = 1)
  (0...n).map { Sham.word }.join(' ').capitalize
end
