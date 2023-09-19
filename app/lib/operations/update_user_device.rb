module Operations
  class UpdateUserDevice
    def self.call(user_id, attrs = {})
      new(user_id, attrs).call
    end

    def initialize(user_id, attrs = {})
      @user_id = user_id
      @token = attrs.fetch(:token, '')
      @platform = attrs.fetch(:platform, '')
    end

    attr_reader :user_id, :token, :platform

    def call
      find_or_create_device
      update_device unless @device.token == token
    end

    private

    def find_or_create_device
      @device = Device.find_by(user_id:, platform:) || Device.create(user_id:, token:, platform:)
    end

    def update_device
      @device.update(token:, platform:)
    end
  end
end
