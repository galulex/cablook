module RepositoryInstances
  def users_repository
    @users_repository ||= Users::Repository.new
  end
end

RSpec.configure do |config|
  config.include(RepositoryInstances)
end
