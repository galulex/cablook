module Operations
  class UpdateUserDevice
    def self.call(user_id, attrs = {})
      new(user_id, attrs).call
    end

    def initialize(user_id, token:, platform:)
      @user_id = user_id
      @token = token
      @platform = platform
    end

    attr_reader :user_id, :token, :platform

    def call
      find_or_create_device
      update_device unless @device.token == token
    end

    private

    def find_or_create_device
      @device = device_repository.by_user(user_id) || device_repository.create(user_id: user_id, token: token, platform: platform)
    end

    def update_device
      device_repository.update(@device.id, token: token, platform: platform)
    end

    def device_repository
      @device_repository ||= Repositories::Device.new(ROM.env)
    end
  end
end
