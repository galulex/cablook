module RepositoryInstances
  def cars_repository
    @cars_repository ||= Repositories::Car.new
  end

  def drivers_repository
    @drivers_repository ||= Repositories::Driver.new
  end

  def feedbacks_repository
    @feedbacks_repository ||= Repositories::Feedback.new
  end

  def subscriptions_repository
    @subscriptions_repository ||= Repositories::Subscription.new
  end

  def trips_repository
    @trips_repository ||= Repositories::Trip.new
  end

  def users_repository
    @users_repository ||= Repositories::User.new
  end
end

RSpec.configure do |config|
  config.include(RepositoryInstances)
end
