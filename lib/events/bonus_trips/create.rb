module Events
  module BonusTrips
    class Create < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          required(:friend_id).filled(:int?)
        end
      end

      def run
        validate_to_similar
        create_bonus_trip
      end

      private

      def validate_to_similar
        invalid!([I18n.t('bonuts_trips.disable_for_yourself')]) if data[:user_id] == data[:friend_id]
      end

      def create_bonus_trip
        Repositories::BonusTrip.new(ROM.env).create(
          user_id: data[:user_id],
          friend_id: data[:friend_id],
          status: bonus_status,
          code: SecureRandom.base58(24),
          type: Constants::BonusTrip::REFERRAL
        )
      end

      def bonus_status
        count = Repositories::Trip.new(ROM.env).count_of_finished_for_user(data[:friend_id])
        if count.positive?
          Constants::BonusTrip::NEW
        else
          Constants::BonusTrip::FROZEN
        end
      end
    end
  end
end
