module RecordedRequestHelpers
  def recorded_request_for(name)
    File.new path_to(name)
  end

  private

  def path_to(name)
    Rails.root.join 'spec', 'fixtures', 'maps', name.to_s
  end
end

RSpec.configure do |config|
  config.include(RecordedRequestHelpers)
end
