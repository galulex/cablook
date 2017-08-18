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
      invalid!(params_validation.messages) unless valid?
      run
    end

    def schema
      Dry::Validation.Schema {}
    end

    def valid?
      params_validation.success?
    end

    def params_validation
      @params_validation ||= schema.call(data)
    end

    def invalid!(errors)
      raise InvalidParamsError, errors.to_json
    end

    def run
      raise NotImplementedError, "#run method is not overridden in #{self.class.name}"
    end
  end
end
