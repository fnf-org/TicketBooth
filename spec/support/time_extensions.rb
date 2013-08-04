# Methods for manipulating time in specs.
class Time
  class << self

    alias old_now now
    def now
      (@fake_now && !@fake_now.empty?) ? @fake_now.last.dup : old_now
    end

    def now=(t)
      raise 'Time.now=() is deprecated, use Time.warp with a block instead'
    end

    def warp(t = Time.now, &block)
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
      if @fake_now.nil? || @fake_now.empty?
        raise 'Time.passes may only be used inside a Time.warp block'
      end
      old_fake = @fake_now.pop || old_now
      @fake_now.push(old_fake + t)
    end
  end
end
