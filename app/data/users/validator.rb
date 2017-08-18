module Users
  class Validator
    include ROM::Model::Validator
    relation :users

    validates :email, uniqueness: true
  end
end
