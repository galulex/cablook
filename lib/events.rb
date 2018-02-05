module Events
  require_relative 'events/base_event'
  require_relative 'events/verifications/send_number_verification'
  require_relative 'events/verifications/verify_number'
  require_relative 'events/authorize_user'
  require_relative 'events/verify_user'
  require_relative 'events/create_driver'
  require_relative 'events/create_feedback'
  require_relative 'events/cars/create'
  require_relative 'events/cars/update'

  InvalidParamsError = Class.new(ArgumentError)
end
