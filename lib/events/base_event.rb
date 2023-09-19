module Events
  class BaseEvent
    def initialize(data = {})
      @data = data
    end

    attr_reader :data

    def self.call(*args)
      new(*args).call
    end

    def call
      validate_params!
      run
    end

    def run
      raise NotImplementedError, "#run method is not overridden in #{self.class.name}"
    end

    private

    def schema
      Dry::Validation.Schema {}
    end

    def validate_params!
      validation = schema.call(data.to_h.symbolize_keys)
      invalid!(validation.message_set) if validation.failure?
    end

    def invalid!(errors, status: 422)
      raise InvalidParamsError.new(status: status), errors.to_json
    end

    def telegram_trip?(user)
      trip_json = Redis.new.get("trip_#{user.telegram.id}")
      return false unless trip_json

      parsed_trip = JSON.parse(trip_json)
      parsed_trip['telegram_trip'] && parsed_trip['id'].present? && parsed_trip['id'] == trip.id
    end

    def settings
      @settings ||= Settings
    end
  end
end
