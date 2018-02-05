module RepositoryInstances
  def bonus_trip_repository
    @bonus_trip_repository ||= Repositories::BonusTrip.new(ROM.env)
  end

  def car_repository
    @car_repository ||= Repositories::Car.new(ROM.env)
  end

  def card_repository
    @card_repository ||= Repositories::Card.new(ROM.env)
  end

  def driver_repository
    @driver_repository ||= Repositories::Driver.new(ROM.env)
  end

  def feedback_repository
    @feedback_repository ||= Repositories::Feedback.new(ROM.env)
  end

  def payment_repository
    @payment_repository ||= Repositories::Payment.new(ROM.env)
  end

  def subscription_repository
    @subscription_repository ||= Repositories::Subscription.new(ROM.env)
  end

  def trip_repository
    @trip_repository ||= Repositories::Trip.new(ROM.env)
  end

  def trip_job_repository
    @trip_job_repository ||= Repositories::TripJob.new(ROM.env)
  end

  def user_repository
    @user_repository ||= Repositories::User.new(ROM.env)
  end
end

RSpec.configure do |config|
  config.include(RepositoryInstances)
end
