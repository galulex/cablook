module RepositoryInstances
  def cars_repository
    @cars_repository ||= Repositories::Car.new
  end

  def drivers_repository
    @drivers_repository ||= Repositories::Driver.new
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
