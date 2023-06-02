module Api
  class SettingsController < ApiApplicationController
    before_action :authorize!

    def show
      render json: Presenters::Settings::UserPublic.new(Settings).to_json, status: 200
    end
  end
end
