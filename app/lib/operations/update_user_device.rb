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
      @device = Device.find_by(user_id: user_id, platform: platform) || Device.create(user_id: user_id, token: token, platform: platform)
    end

    def update_device
      @device.update(token: token, platform: platform)
    end
  end
end
