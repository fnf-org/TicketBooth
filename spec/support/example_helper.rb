# frozen_string_literal: true

class ExampleHelper
  attr_accessor :example_count, :example_timings
  attr_reader :config, :timeout, :max_width, :wrap_on_width

  def initialize(config:, timeout: 20, max_width: 80)
    @example_count = 0
    @example_timings = []
    @config = config
    @timeout = timeout

    if ARGV.include?('--format') && ARGV.include?('documentation')
      @max_width = 90
      @wrap_on_width = false
    else
      @max_width = max_width
      @wrap_on_width = true
    end
  end

  def wrap_example!
    this = self
    @config.around do |example|
      if this.example_count % this.max_width == 0
        this.example_timings.clear if this.wrap_on_width
        puts if this.wrap_on_width
      end

      this.example_count += 1
      this.example_with_timeout(example)
    end
  end

  def example_with_timeout(example)
    Timeout.timeout(timeout) do
      t1 = Time.now.to_f

      example.run

      t2 = Time.now.to_f
      duration = ((t2 - t1) * 1000).to_i
      @example_timings << duration
      print_timings(duration, example)
    end
  rescue Timeout::Error
    warn "\033[31m"
    warn "[ 𐄂 ] RSpec Failed with timeout of #{timeout} seconds"
    warn "      • Example:  #{example.full_description}"
    warn "      • Location: #{example.location}"
  end

  def print_timings(duration, example)
    color = if example&.execution_result&.status == :failed
              "\033[31m"
            else
              "\033[32m"
            end
    # ANSI Codes:
    #
    #  1. save current position
    #  2. move up one line
    #  3. move left 80 (to ensure we are counting from 0)
    #  4. move right by 80
    #  5. restore position
    #
    $stderr.printf "\033[s\033[1A\033[10000D\033[#{max_width}C#{color} %7d tests | %6.2fs duration | %6dms avg | %5dms last \033[u",
                   example_timings.size,
                   example_timings.sum / 1000.0,
                   example_timings.avg,
                   duration
  end
end
