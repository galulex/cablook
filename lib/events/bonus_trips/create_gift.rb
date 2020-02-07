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
        create_bonus_trip
      end

      private

      def create_bonus_trip
        BonusTrip.create(
          user_id: data[:user_id],
          status:  Constants::BonusTrip::STATUSES[Constants::BonusTrip::FRESH],
          code: SecureRandom.base58(24),
          type: Constants::BonusTrip::GIFT
        )
      end
    end
  end
end
