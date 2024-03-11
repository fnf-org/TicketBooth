# frozen_string_literal: true

# Methods for manipulating time in specs.
class Time
  class << self
    alias old_now now
    def now
      @fake_now.present? ? @fake_now.last.dup : old_now
    end

    def now=(_t)
      raise 'Time.now=() is deprecated, use Time.warp with a block instead'
    end

    def warp(t = Time.zone.now)
      raise ArgumentError, 'Time.warp requires a block' unless block_given?
      raise ArgumentError, 'Time.warp passed nil' if t.nil?
      raise ArgumentError, '`t` must respond to #to_time' unless t.respond_to?(:to_time)

      @fake_now = @fake_now ? @fake_now.push(t.to_time) : [t.to_time]
      begin
        yield
      ensure
        @fake_now.pop
      end
    end

    def passes(t)
      raise 'Time.passes may only be used inside a Time.warp block' if @fake_now.blank?

      old_fake = @fake_now.pop || old_now
      @fake_now.push(old_fake + t)
    end
  end
end
