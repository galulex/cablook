module RepositoryInstances
  def cars_repository
    @cars_repository ||= Repositories::Car.new(ROM.env)
  end

  def cards_repository
    @cards_repository ||= Repositories::Card.new(ROM.env)
  end

  def drivers_repository
    @drivers_repository ||= Repositories::Driver.new(ROM.env)
  end

  def feedbacks_repository
    @feedbacks_repository ||= Repositories::Feedback.new(ROM.env)
  end

  def subscriptions_repository
    @subscriptions_repository ||= Repositories::Subscription.new(ROM.env)
  end

  def trips_repository
    @trips_repository ||= Repositories::Trip.new(ROM.env)
  end

  def users_repository
    @users_repository ||= Repositories::User.new(ROM.env)
  end
end

RSpec.configure do |config|
  config.include(RepositoryInstances)
end
