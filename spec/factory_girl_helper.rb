require 'factory_girl'

# Convenience methods added to invoke Factory Girl factories by sending
# messages directly to ActiveRecord classes.
#
# We use these rather than the one provided by Factory Girl itself
# (factory_girl/syntax/make) because we want wrappers for all four methods,
# not just "create", and we also want the option of customising the returned
# instance via a block.
class ActiveRecord::Base
  class << self

    # Wrapper for FactoryGirl.build
    def make(*args, &block)
      make_with(name.underscore, *args, &block)
    end

    # Like #make, but allows the caller to explicitly specify a factory name.
    def make_with(factory_name, *args, &block)
      factory_girl_delegate :build, factory_name, *args, &block
    end

    # Wrapper for FactoryGirl.create
    def make!(*args, &block)
      make_with!(name.underscore, *args, &block)
    end

    # Like #make!, but allows the caller to explicitly specify a factory name.
    def make_with!(factory_name, *args, &block)
      factory_girl_delegate :create, factory_name, *args, &block
    end

    # Wrapper for FactoryGirl.attributes_for
    def valid_attributes(*args, &block)
      valid_attributes_with(name.underscore, *args, &block)
    end

    # Like #valid_attributes, but allows the caller to explicitly specify a
    # factory name.
    def valid_attributes_with(factory_name, *args, &block)
      factory_girl_delegate :attributes_for, factory_name, *args, &block
    end

  private

    def factory_girl_delegate(method, factory_name, *args, &block)
      object = FactoryGirl.send method, factory_name, *args
      yield object if block_given?
      object
    end
  end
end

# Shams were a feature of Factory Girl until version 4.0. This is a thin wrapper
# that allows us to continue using Shams (as they're very simple).
module Sham
  def self.method_missing(method, *args, &block)
    if args.any?
      raise ArgumentError, "Sham.#{method} called with #{args.inspect}"
    end

    if block_given? # defining a Sham
      FactoryGirl.define do
        sequence method, &block
      end
    else # using a Sham
      FactoryGirl.generate method
    end
  end
end

Sham.email_address do |n|
  "#{Sham.word.downcase}#{n}@example.com"
end

Sham.positive_integer { |n| n }

Sham.street_address do |n|
  "#{n} #{Sham.words(2)} Street"
end

# Produce a zip code, starting at 10,000.
Sham.zip_code do |n|
  '%.5d' % (n + 10_000)
end

# Generate a random string of length k.
def Sham.string(k)
  chars =  ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  1.upto(k).inject('') { |string, _| string + chars[rand(chars.size - 1)] }
end

# Generate a random but prounounceable word.
# Modified from: http://snipplr.com/view.php?codeview&id=1247
def Sham.word(n = [2,4,6].sample)
  c = %w(b c d f g h j k l m n p qu r s t v w x z) +
      %w(ch cr fr ph pr sh sl sp st th tr)
  v = %w(a e i o u y)
  e = %w(ch nd ng nk nt ph rd sh sp st)
  suf = (rand > 0.5) ? e.sample : ''
  f = false
  (0...n).map { (f = !f) ? c.sample : v.sample }.join + suf
end

# Generate a sentence of n random but pronounceable words.
def Sham.words(n = 1)
  (0...n).map { Sham.word }.join(' ').capitalize
end
