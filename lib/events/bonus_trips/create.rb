module Events
  module BonusTrips
    class Create < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          optional(:friend_id).filled(:int?)
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
        Repositories::BonusTrip.new(ROM.env).create(data.to_h.merge(code: SecureRandom.base58(24)))
      end
    end
  end
end
