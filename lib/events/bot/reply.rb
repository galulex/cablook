module Events
  module Bot
    class Reply < BaseEvent
      COMMANDS = %w[BOOK CORRECT INCORRECT CANCEL GO TRY\ AGAIN].freeze

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
        command ||= data[:text].downcase.gsub(' ', '_') if COMMANDS.include?(data[:text])
        case telegram_order.step
        when 'start'
          telegram_order.start
        when 'request_departure_address'
          return telegram_order.perform(command) if command
          location = Places.new(data[:text]).location
          if location
            telegram_order.trip = { departure_address: data[:text], departure: location_string(location) }
            telegram_order.send_location(location)
          else
            telegram_order.send_message :incorect_address
          end
        when 'request_destination_address'
          return telegram_order.perform(command) if command
          location = Places.new(data[:text]).location
          if location
            telegram_order.update_trip(destination_address: data[:text], destination: location_string(location))
            telegram_order.send_location(location)
          else
            telegram_order.send_message :incorect_address
          end
        when 'book'
          telegram_order.perform(command) if command
        when 'confirm_trip'
          telegram_order.perform(command) if command
        when 'rate_trip'
          rating = data[:text].to_i
          if rating.between?(1, 5)
            telegram_order.compose_feedback({ rate: rating }, :tips)
          else
            telegram_order.send_message(:incorrect_rating)
          end
        when 'tips'
          tip = data[:text]
          telegram_order.compose_feedback({ tip: tip.to_i }, :tips_accept) if tip.match?(/3|5|10|20/)
          telegram_order.create_feedback
        end
      end

      private

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

      def entity
        @entity ||= data[:entities]&.find { |e| e['type'] == 'bot_command' }
      end
    end
  end
end
