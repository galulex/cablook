module Repositories
  class User < ROM::Repository[:users]
    commands :create, update: :by_pk, delete: :by_pk

    def all
      users.to_a
    end

    def by_email(email)
      users.where(email: email).one
    end

    def by_phone_number(phone_number)
      users.where(phone_number: phone_number).one
    end

    def by_token(auth_token)
      users.where(auth_token: auth_token).one
    end
  end
end
