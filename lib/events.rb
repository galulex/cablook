module Events
  require_relative 'events/base_event'
  require_relative 'events/verifications/send_number_verification'
  require_relative 'events/verifications/verify_number'
  require_relative 'events/authorization'
  require_relative 'events/create_car'
  require_relative 'events/create_driver'
  require_relative 'events/create_feedback'
  require_relative 'events/create_trip'
  require_relative 'events/create_user'

  InvalidParamsError = Class.new(ArgumentError)
end
