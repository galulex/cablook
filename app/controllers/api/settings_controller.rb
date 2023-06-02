module Api
  class SettingsController < ApiApplicationController
    before_action :authorize!

    def show
      render json: { settings: Settings.last }, status: 200
    end
  end
end
