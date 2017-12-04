module Events
  class CreateCard < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:cardPan).filled(:str?)
        required(:recToken).filled(:str?)
        required(:user_id).filled(:int?)
      end
    end

    def run
      find_user!
      validate_card!
      create_card
    end

    private

    def find_user!
      invalid!([I18n.t('cards.user_not_found')]) unless user
    end

    def validate_card!
      validator = Validators::Card.new(card_params)
      invalid!(validator.errors.full_messages) if validator.invalid?
    end

    def create_card
      Repositories::Card.new(ROM.env).create(card_params)
    end

    def card_params
      {
        token: data[:recToken],
        pan: data[:cardPan],
        user_id: data[:user_id]
      }
    end

    def user
      @user ||= Repositories::User.new(ROM.env).by_id(data[:user_id])
    end
  end
end
