module Superbara
  def wait(seconds=5, &block)
    raise "block not given" unless block

    def wait_formatted_output(status, took_delta)
      word, color = if status
        ["ok", :green]
      else
        ["FAIL", :red]
      end

    end

    seconds = seconds.to_f
    source_path, source_line = block.source_location

    open(source_path).each_with_index do |line, i|
      next if i < source_line
      break if line.start_with? "end"
      formatted_line = line.gsub("\n", "").lstrip
    end

    started_at = Time.now
    previous_capybara_default_max_wait_time = Capybara.default_max_wait_time
    block_value = nil
    exception = nil
    timed_out = false
    begin
      Capybara.default_max_wait_time = seconds
      Timeout::timeout (seconds+0.1) do
        loop do
          block_value = block.call
          case block_value
          when false, nil, []
            sleep 0.1
          else
            break
          end
        end
      end
    rescue Timeout::Error => ex
      timed_out = true
    rescue Exception => ex
      exception = ex
    end

    took_delta = (Time.now - started_at).floor(2)
    Capybara.default_max_wait_time = previous_capybara_default_max_wait_time

    if exception || timed_out
      wait_formatted_output false, took_delta

      additional_started_at = Time.now
      additional_block_value = nil
      additional_exception = nil
      previous_default_max_wait_time = Capybara.default_max_wait_time
      puts "  testing if waiting for 2 seconds more would help.."
      begin
        Timeout::timeout(2.1) do
          Capybara.default_max_wait_time = 2
          additional_block_value = block.call
        end
      rescue Exception => ex
        additional_exception = ex
      ensure
        Capybara.default_max_wait_time = previous_default_max_wait_time
      end

      additional_took_delta = (Time.now - additional_started_at).floor(2)
      suggested_wait_value = (seconds + additional_took_delta).floor(2)

      if additional_exception || additional_block_value.nil?
        puts "  ..did not help."
      else
        puts "  ..setting wait to >#{suggested_wait_value} would help here?"
      end

      if exception
        raise exception
      else
        raise "capybara timed out"
      end
    end

    if block_value == false
      wait_formatted_output false, took_delta
      raise "wait condition was falsy"
    end

    if block_value == nil
      wait_formatted_output false, took_delta
      raise "wait condition was nil"
    end

    self.wait_formatted_output true, took_delta
    return block_value
  end
end

RSpec.configure do |config|
  config.include(Superbara)
end
