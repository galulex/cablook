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
      validation = schema.call(data)
      invalid!(validation.messages) if validation.failure?
    end

    def invalid!(errors)
      raise InvalidParamsError, errors.to_json
    end
  end
end
