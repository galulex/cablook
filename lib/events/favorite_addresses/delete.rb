module Events
  module FavoriteAddresses
    class Delete < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:id).filled(:int?)
          required(:user_id).filled(:int?)
        end
      end

      def run
        favorite_address&.delete
      end

      private

      def favorite_address
        @favorite_addresses ||= FavoriteAddress.find_by(user_id: data[:user_id], id: data[:id])
      end
    end
  end
end
