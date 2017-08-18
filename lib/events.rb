module Events
  require_relative 'events/base_event'

  InvalidParamsError = Class.new(ArgumentError)
end
