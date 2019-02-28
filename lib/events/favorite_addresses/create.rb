module Events
  module FavoriteAddresses
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:name).filled(:str?)
          required(:location).filled(:str?).value(format?: Constants::Regex::LOCATION_COORDINATES)
          required(:user_id).filled(:int?)
        end
      end

      def run
        find_user!
        validate!
        create_favorite_address
        @favorite_address
      end

      private

      def find_user!
        invalid!([I18n.t('cards.user_not_found')]) unless user
      end

      def validate!
        @favorite_address = user.favorite_addresses.new(favorite_address_params)
        invalid!(@favorite_address.errors.values.flatten) if @favorite_address.invalid?
      end

      def create_favorite_address
        @favorite_address.save
      end

      def favorite_address_params
        {
          name: data[:name],
          location: data[:location],
          user_id: data[:user_id]
        }
      end

      def user
        @user ||= User.find(data[:user_id])
      end
    end
  end
end
