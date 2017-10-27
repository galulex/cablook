module Events
  class Drivers::Authentication < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:username).filled(:str?)
        required(:password).filled(:str?)
      end
    end

    def run
      driver = Repositories::Driver.new.by_username(data[:username])
      if driver
        password = BCrypt::Password.new(driver.encrypted_password)
        return driver if password == data[:password]
      end
      invalid!(driver: ['Username or password is invalid'])
    end
  end
end
