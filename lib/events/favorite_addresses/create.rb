module Events
  module FavoriteAddresses
    class Create < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:name).filled(:str?)
          required(:location).filled(format?: Constants::Regex::LOCATION_COORDINATES)
          required(:address).filled(:str?)
          required(:user_id).filled(:int?)
        end
      end

      def run
        FavoriteAddress.create(data)
      end
    end
  end
end
