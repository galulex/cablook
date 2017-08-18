module Events
  require_relative 'events/base_event'
  require_relative 'events/create_user'

  InvalidParamsError = Class.new(ArgumentError)
end
