module Events
  module Drivers
    class Notify < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          required(:message_type).filled(:str?)
          optional(:message).maybe(:str?)
        end
      end

      def run
        broadcast
      end

      private

      def broadcast
        message = set_message
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFY_DRIVER,
          data: {
            phone_number: trip.user.phone_number,
            message: message
          }.to_json
        ) 
      end

      def set_message
        case data[:message_type]
        when 'reply'
          data[:message]
        when 'coming'
          I18n.t('notification.coming')
        when 'coming_click'
          I18n.t('notification.coming_click')
        end
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end
    end
  end
end
