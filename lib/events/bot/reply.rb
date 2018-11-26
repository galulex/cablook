module Events
  module Bot
    class Reply < BaseEvent
      COMMANDS = %w[BOOK CORRECT INCORRECT CANCEL GO].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
        end
      end

      def run
        p '!' * 100
        return register if data['contact']
        command = data['data']
        command ||= data['text'].slice(entity[:offset] + 1, entity[:length]) if entity
        command ||= data[:text].downcase if COMMANDS.include?(data[:text])
        if command
          send(command)
        else
          location = Places.new(data[:text]).location
          if location
            # if trip[:destination]
            #   add_waypoint_to_trip(location, data[:text])
            # elsif trip[:departure]
            #   update_trip(destination_address: data[:text], destination: location_string(location))
            # else
            #   self.trip = { departure_address: data[:text], departure: location_string(location) }
            # end
            case step
            when 'request_departure_address'
              self.trip = { departure_address: data[:text], departure: location_string(location) }
            when 'request_destination_address'
              self.trip = trip.merge(destination_address: data[:text], destination: location_string(location))
            end
            current_user.reply(:send_location, :confirm_address, latitude: location['lat'], longitude: location['lng'])
          else
            send_message :incorect_address
          end
        end
      end

      private

      def correct
        p step
        case step
        when 'request_departure_address'
          self.step = :request_destination_address
          send_message :request_destination_address
        when 'request_destination_address'
          self.trip = Events::Trips::Build.(trip.merge(user_id: current_user.user_id, comment: '')).as_json(methods: :image)
          current_user.reply(:send_photo, :confirm_trip, photo: trip[:image])
          send_message :confirm_trip
          self.step = :confirm_trip
        end
      end

      def incorrect
        p step
        case step
        when 'request_departure_address'
          self.trip = {}
          send_message :request_departure_address
        when 'request_destination_address'
          self.trip = trip.except(:destination, :destination_address)
          send_message :request_destination_address
        end
      end

      def go
        Events::Trips::Create.(trip.merge(user_id: current_user.user_id, comment: ''))
        send_message :looking_for_car
      end

      def cancel
        self.trip = {}
        send_message(:start)
      end

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
        self.trip = Events::Trips::Build.(trip.merge(user_id: current_user.user_id)).as_json
        send_message(:confirm_trip)
      end

      def add_waypoint
        send_message(:request_waypoint_address)
      end

      def remove_last_waypoint
        update_trip(stops: trip[:stops][0...-1], waypoints: trip[:waypoints][0...-1])
      end

      def add_waypoint_to_trip(location, stop_address)
        initialize_waypoints unless trip[:waypoints]
        update_trip(stops: trip[:stops] << stop_address, waypoints: trip[:waypoints] << location_string(location))
      end

      def initialize_waypoints
        update_trip(stops: [], waypoints: [])
      end

      def location_string(location)
        "#{location['lat']},#{location['lng']}"
      end

      def entity
        @entity ||= data[:entities]&.find { |e| e['type'] == 'bot_command' }
      end

      def start
        send_message(current_user.persisted? ? :start : :request_contact)
      end

      def book
        self.step = :request_departure_address
        send_message :request_departure_address
      end

      def register
        User.from_telegram(data.dig(:contact, :phone_number), data.dig(:from, :username), chat)
        send_message :start
      end

      def current_user
        @current_user ||= UserTelegram.find_or_initialize_by(username: data[:from][:username], chat_id: chat)
      end

      def send_message(action)
        current_user.reply(:send_message, action)
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

      def step=(val)
        Redis.current.set("user_#{current_user.id}_step", val)
      end

      def step
        Redis.current.get("user_#{current_user.id}_step") || :start
      end
    end
  end
end
