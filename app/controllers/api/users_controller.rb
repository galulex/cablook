module Api
  class UsersController < ApiApplicationController
    before_action :authorize!, :set_paper_trail_whodunnit
    before_action :prevent_page_caching, only: :show

    def show
      response = user.as_json(only: %i[id email phone_number locale],
                              include: %i[favorite_addresses parent_bonus],
                              methods: %i[enabled_notifications current_trip current_delivery_trip])
      response['cards'] = Card.user_cards(user.id).as_json
      response['bonus_trips'] = settings.bonuses ? user.bonus_trips.as_json : []
      response['cashback'] = settings.cashback ? user.cashback : 0
      response['settings'] = Presenters::Settings::UserPublic.new(settings).to_json
      render json: response, status: 200
    end

    def update
      Events::Users::Update.(user_id: user.id, locale: params[:locale])
    end

    def destroy
      Events::Users::Remove.(user_id: user.id)
    end

    private

    def user
      current_user
    end

    def prevent_page_caching
      response.headers['Cache-Control'] = 'no-cache, no-store'
      response.headers['Pragma']        = 'no-cache'
      response.headers['Expires']       = '0'
    end
  end
end
