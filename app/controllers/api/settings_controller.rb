module Api
  class SettingsController < ApiApplicationController
    def show
      render json: settings.to_json, status: 200
    end

    private

    def settings
      return Presenters::Settings::UserPublic.new(Settings) if current_user

      Presenters::Settings::Public.new(Settings)
    end
  end
end
