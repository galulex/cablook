module Events
  module Bot
    class Reply < BaseEvent
      COMMANDS = %w[/start BOOK CORRECT INCORRECT CANCEL GO TRY\ AGAIN YES NO].freeze
      COMMANDLESS_STEPS = %w[waypoints_confirmation comment_confirmation comment rate_trip tips].freeze
      TIPS_REGEXP = /3|5|10|20/.freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
        end
      end

      def run
        return register if data['contact']
        command ||= parse_command(data)
        return telegram_order.perform(command) if COMMANDLESS_STEPS.exclude?(step) && command
        case step
        when 'request_departure_address'
          update_address(data[:text], 'departure')
        when 'request_destination_address'
          update_address(data[:text], 'destination')
        when 'waypoints_confirmation'
          command == 'yes' ? telegram_order.confirm_waypoints : telegram_order.finish_waypoints
        when 'initial_waypoint'
          update_waypoint(data[:text], true)
        when 'waypoint'
          update_waypoint(data[:text])
        when 'comment_confirmation'
          telegram_order.update_trip({ comment: '' })
          command == 'yes' ? telegram_order.confirm_comment : telegram_order.skip_comment
        when 'comment'
          telegram_order.update_trip({ comment: data[:text] })
          telegram_order.skip_comment
        when 'rate_trip'
          rate_trip(data)
        when 'tips'
          add_tips(data)
        end
      end

      private

      def update_address(address, field)
        location = Places.new(address).location
        return telegram_order.send_message(:incorect_address) unless location
        telegram_order.update_trip(Hash["#{field}_address".to_sym, address, field.to_sym, location_string(location)])
        telegram_order.send_location(location)
      end

      def update_waypoint(address, initial = false)
        location = Places.new(address).location
        return telegram_order.send_message(:incorect_address) unless location
        initial ? telegram_order.step = :waypoint : telegram_order.remove_last_waypoint
        telegram_order.add_waypoint(address, location_string(location))
        telegram_order.send_location(location)
      end

      def rate_trip(data)
        rating = data[:text].to_i
        if rating.between?(1, 5)
          telegram_order.compose_feedback({ rate: rating }, :tips)
        else
          telegram_order.send_message(:incorrect_rating)
        end
      end

      def add_tips(data)
        tip = data[:text]
        telegram_order.compose_feedback({ tip: tip.to_i }, :tips_accept) if tip.match?(TIPS_REGEXP)
        telegram_order.create_feedback
      end

      def step
        telegram_order.step
      end

      def parse_command(data)
        data[:text].downcase.gsub(' ', '_').remove('/') if COMMANDS.include?(data[:text])
      end

      def register
        User.from_telegram(data.dig(:contact, :phone_number), data.dig(:from, :username), chat)
        telegram_order.send_message :start
      end

      def current_user
        @current_user ||= UserTelegram.find_or_initialize_by(username: @data[:from][:username], chat_id: chat)
      end

      def telegram_order
        @telegram_order ||= TelegramOrder.new(current_user)
      end

      def chat
        @chat ||= @data.dig(:chat, :id) || @data.dig(:message, :chat, :id)
      end

      def location_string(location)
        "#{location['lat']},#{location['lng']}"
      end
    end
  end
end
