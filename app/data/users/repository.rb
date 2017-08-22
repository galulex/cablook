module Users
  class Repository < ROM::Repository[:users]
    relations :users

    commands :create, update: :by_pk, delete: :by_pk

    def initialize
      super(ROM.env)
    end

    def all
      users.to_a
    end

    def by_email(email)
      users.where(email: email).one
    end

    # TODO: Add index to DB
    def by_token!(auth_token)
      users.where(auth_token: auth_token).one!
    end
  end
end
