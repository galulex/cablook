module Events
  class Authorization < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
        required(:password).filled(:str?)
      end
    end

    def run
      user = Repositories::User.new.by_phone_number(data[:phone_number])
      if user
        password = BCrypt::Password.new(user.encrypted_password)
        return user if password == data[:password]
      end
      invalid!(user: ['Phone number or password is invalid'])
    end
  end
end
