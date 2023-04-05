module Events
  module Users
    class AddReferral < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:referral_code).filled(:str?)
          required(:referral_id).filled(:int?)
        end
      end

      def run
        check_for_referrer
        validate!
        # Events::BonusTrips::Create.(user_id: referrer.id, friend_id: data[:referral_id])
      end

      private

      def validate!
        bonuses = BonusTrip.where(friend_id: data[:referral_id])
        invalid!([I18n.t('bonus_trips.already_have_referrer')]) if bonuses.any?
      end

      def check_for_referrer
        raise Constants::NotFoundError unless referrer
      end

      def referrer
        @referrer ||= User.find_by(referral_code: data[:referral_code])
      end
    end
  end
end
