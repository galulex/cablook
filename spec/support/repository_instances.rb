module RepositoryInstances
  def users_repository
    @users_repository ||= Repositories::User.new
  end

  def drivers_repository
    @drivers_repository ||= Repositories::Driver.new
  end

  def trips_repository
    @trips_repository ||= Repositories::Trip.new
  end
end

RSpec.configure do |config|
  config.include(RepositoryInstances)
end
