module Events
  class Authorization < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone_number).value(size?: 12)
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
