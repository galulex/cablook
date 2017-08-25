module Feedbacks
  class Repository < ROM::Repository[:feedbacks]
    relations :feedbacks

    commands :create

    def initialize
      super(ROM.env)
    end
  end
end
