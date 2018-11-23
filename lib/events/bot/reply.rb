module Events
  module Bot
    class Reply < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
        end
      end

      def run
        # return if data['data'].blank? && entity.blank? && data['contact'].blank?
        p '!' * 100
        return register if data['contact']
        command = data['data']
        command ||= data['text'].slice(entity[:offset] + 1, entity[:length]) if entity
        if command
          send(command)
        else
          location = Places.new(data[:text]).location
          if location
            if trip['departure']
              self.trip = trip.merge(destination_address: data[:text], destination: "#{location['lat']},#{location['lng']}")
            else
              self.trip = { departure_address: data[:text], departure: "#{location['lat']},#{location['lng']}" }
            end
            reply(:send_location, :send_location, latitude: location['lat'], longitude: location['lng'])
          else
            send_message :incorect_address
          end
        end
        # if (command = data['text'].to_s.match(%r{\/(.*)}))
        #   send(command.captures.first)
        # elsif data['contact']
        #   register
        # elsif data['location']
        #   update_location
        # end
      end

      private

      def confirm_address
        send_message(trip[:destination] ? :done : :request_departure_address)
      end

      def reject_address
        if trip['destination']
          self.trip = trip.except('destination', 'destination_address')
          confirm_address
        else
          self.trip = {}
          book
        end
      end

      def entity
        @entity ||= data[:entities]&.find { |e| e['type'] == 'bot_command' }
      end

      def start
        send_message(current_user ? :book : :request_contact)
      end

      def book
        send_message :request_departure_address
      end

      def register
        User.from_telegram(data.dig(:contact, :phone_number), data.dig(:from, :username))
        send_message :book
      end

      def current_user
        @current_user ||= User.find_by(telegram_username: data[:from][:username])
      end

      def send_message(action)
        reply(:send_message, action)
      end

      def reply(action, message, attrs = {})
        Telegram.bot.send(action, I18n.t("bot.#{message}").merge(chat_id: chat).merge(attrs))
      end

      def chat
        @chat ||= data.dig(:chat, :id) || data.dig(:message, :chat, :id)
      end

      def trip
        JSON.parse(Redis.current.get("trip_#{current_user.id}"))
      end

      def trip=(attrs)
        Redis.current.set("trip_#{current_user.id}", attrs.to_json)
      end
    end
  end
end
