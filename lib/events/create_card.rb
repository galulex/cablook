module Events
  class CreateCard < BaseEvent
    def schema
      Dry::Validation.Schema do
        configure { config.messages = :i18n }

        required(:cardPan).filled(:str?)
        required(:recToken).filled(:str?)
        required(:user_id).filled(:int?)
        optional(:cardType).filled(:str?)
        optional(:currency).filled(:str?)
        optional(:email).filled(:str?)
      end
    end

    def run
      find_user!
      validate_card!
      update_user_email
      create_card
    end

    private

    def find_user!
      invalid!([I18n.t('cards.user_not_found')]) unless user
    end

    def validate_card!
      validator = Validators::Card.new(card_params)
      invalid!(validator.errors.values.flatten) if validator.invalid?
    end

    def create_card
      Repositories::Card.new(ROM.env).create(card_params)
    end

    def update_user_email
      Repositories::User.new(ROM.env).update(user.id, email: data[:email])
    end

    def card_params
      {
        token: data[:recToken],
        pan: data[:cardPan],
        type: data[:cardType],
        currency: data[:currency],
        user_id: data[:user_id]
      }
    end

    def user
      @user ||= Repositories::User.new(ROM.env).by_id(data[:user_id])
    end
  end
end
