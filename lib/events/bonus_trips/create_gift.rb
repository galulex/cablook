module Events
  module BonusTrips
    class CreateGift < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
        end
      end

      def run
        # create_bonus_trip
        show_message
      end

      private

      def show_message
        invalid!(['Unavailable'])
      end

      def create_bonus_trip
        BonusTrip.create(
          user_id: data[:user_id],
          status: :fresh,
          code: SecureRandom.base58(24),
          type: Constants::BonusTrip::GIFT
        )
      end
    end
  end
end
