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
  end
end
