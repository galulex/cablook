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
            if trip[:destination]
              add_waypoint_to_trip(location, data[:text])
            elsif trip[:departure]
              update_trip({ destination_address: data[:text], destination: location_string(location) })
            else
              self.trip = { departure_address: data[:text], departure: location_string(location) }
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
        send_message(trip[:destination] ? :waypoints_confirmation : :request_destination_address)
      end

      def reject_address
        if trip[:waypoints]
          remove_last_waypoint
          add_waypoint
        elsif trip[:destination]
          self.trip = trip.except(:destination, :destination_address)
          confirm_address
        else
          self.trip = {}
          book
        end
      end

      def reject_waypoints
        built_trip = Events::Strips::Build.(trip.merge(user_id: current_user.id))
        #TODO send confirmation message containing trip general details
      end

      def add_waypoint
        send_message(:request_waypoint_address)
      end

      def remove_last_waypoint
        update_trip({ stops: trip[:stops][0...-1], waypoints: trip[:waypoints][0...-1] })
      end

      def add_waypoint_to_trip(location, stop_address)
        initialize_waypoints unless trip[:waypoints]
        update_trip({ stops: trip[:stops] << stop_address, waypoints: trip[:waypoints] << location_string(location) })
      end

      def initialize_waypoints
        update_trip({ stops: [], waypoints: [] })
      end

      def location_string(location)
        "#{location['lat']},#{location['lng']}"
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
        JSON.parse(Redis.current.get("trip_#{current_user.id}") || '{}', symbolize_names: true)
      end

      def trip=(attrs)
        Redis.current.set("trip_#{current_user.id}", attrs.to_json)
      end

      def update_trip(args)
        self.trip = trip.merge(args)
      end
    end
  end
end
