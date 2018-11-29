module Events
  module Bot
    class Reply < BaseEvent
      COMMANDS = %w[/start BOOK CORRECT INCORRECT CANCEL GO TRY\ AGAIN YES NO].freeze
      COMMANDLESS_STEPS = %w[waypoints_confirmation comment_confirmation comment rate_trip tips].freeze
      TIPS_REGEXP = /3|5|10|20/

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
        end
      end

      def run
        return register(data[:cards_url]) if data['contact']
        @text = data[:text]
        @command ||= parse_command(@text)
        return telegram_order.perform(@command) if COMMANDLESS_STEPS.exclude?(step) && @command
        send(step) if respond_to?(step, true)
      end

      private

      def request_departure_address
        process_address(@text, 'departure')
      end

      def request_destination_address
        process_address(@text, 'destination')
      end

      def waypoints_confirmation
        @command == 'yes' ? telegram_order.confirm_waypoints : telegram_order.update_step(:comment_confirmation)
      end

      def initial_waypoint
        process_address(@text, 'waypoint', true)
      end

      def waypoint
        process_address(@text, 'waypoint')
      end

      def comment_confirmation
        telegram_order.update_trip(comment: '')
        @command == 'yes' ? telegram_order.update_step(:comment) : telegram_order.skip_comment
      end

      def comment
        telegram_order.update_trip(comment: @text)
        telegram_order.skip_comment
      end

      def process_address(address, field, initial = nil)
        location = Places.new(address).location
        return telegram_order.send_message(:incorect_address) unless location
        field == 'waypoint' ? update_waypoint(address, location, initial) : update_address(address, location, field)
      end

      def update_address(address, location, field)
        telegram_order.update_trip(Hash["#{field}_address".to_sym, address, field.to_sym, location_string(location)])
        telegram_order.reply(:send_location, :confirm_address, latitude: location['lat'], longitude: location['lng'])
      end

      def update_waypoint(address, location, initial)
        initial ? telegram_order.step = :waypoint : telegram_order.remove_last_waypoint
        telegram_order.add_waypoint(address, location_string(location))
        telegram_order.reply(:send_location, :confirm_address, latitude: location['lat'], longitude: location['lng'])
      end

      def rate_trip
        rating = data[:text].to_i
        if rating.between?(1, 5)
          telegram_order.compose_feedback({ rate: rating }, :tips)
        else
          telegram_order.send_message(:incorrect_rating)
        end
      end

      def select_card
        telegram_order.add_card(@text)
      end

      def tips
        tip = data[:text]
        telegram_order.compose_feedback({ tip: tip.to_i }, :tips_accept) if tip.match?(TIPS_REGEXP)
        telegram_order.create_feedback
      end

      def step
        telegram_order.step
      end

      def parse_command(text)
        text.downcase.tr(' ', '_').remove('/') if COMMANDS.include?(text)
      end

      def register(cards_url)
        User.from_telegram(data.dig(:contact, :phone_number), data.dig(:from, :username), chat)
        if telegram_order.user.cards.empty?
          telegram_order.reply(:send_message, :request_card, reply_markup: add_card_button(cards_url))
          telegram_order.step = :request_card
        else
          telegram_order.send_message :start
        end
      end

      def add_card_button(cards_url)
        { inline_keyboard: [[{ text: '+', url: "#{cards_url}?auth=#{telegram_order.user.auth_token}" }]] }
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
