module Events
  require_relative 'events/base_event'
  require_relative 'events/users/authorize'
  require_relative 'events/drivers/create'
  require_relative 'events/feedbacks/create'
  require_relative 'events/cars/create'
  require_relative 'events/cars/update'

  class InvalidParamsError < ArgumentError
    attr_reader :object

    def initialize(object)
      @object = object
    end
  end
end
