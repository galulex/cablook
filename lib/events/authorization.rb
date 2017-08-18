require_relative 'base_event'

module Events
  class Authorization < BaseEvent
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

    def schema
      Dry::Validation.Schema do
        required(:email).filled(format?: EMAIL_REGEX)
        required(:password).filled(:str?)
      end
    end

    def run
      user = Users::Repository.new.by_email(data[:email])
      if user
        password = BCrypt::Password.new(user.encrypted_password)
        return user if password == data[:password]
      end
      invalid!(user: ['Email or password is invalid'])
    end
  end
end
