module Events
  class CreateCard < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone).filled(:str?)
        required(:cardPan).filled(:str?)
        required(:recToken).filled(:str?)
        required(:transactionStatus).filled(:str?)
      end
    end

    def run
      validate_transaction_status
      find_user!
      validate_card!
      create_card
    end

    private

    def validate_transaction_status
      return if data[:transactionStatus] == Constants::Card::APPROVED
      invalid!([I18n.t('en.cards.something_went_wrong')])
    end

    def find_user!
      invalid!([I18n.t('en.cards.user_not_found')]) unless user
    end

    def validate_card!
      validator = Validators::Card.new(card_params)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_card
      Repositories::Card.new(ROM.env).create(card_params)
    end

    def card_params
      {
        token: data[:recToken],
        pan: data[:cardPan],
        user_id: user.id
      }
    end

    def user
      @user ||= Repositories::User.new(ROM.env).by_phone_number(data[:phone])
    end
  end
end
