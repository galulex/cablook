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
            Telegram.bot.send_location chat_id: chat, latitude: location['lat'], longitude: location['lng'], reply_markup: { inline_keyboard: [[text: 'Yes', callback_data: 'confirm_address'], [text: 'No', callback_data: 'reject_addess']] }
          else
            send_message 'incorect address'
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

      end

      def reject_addess

      end

      def entity
        @entity ||= data[:entities]&.find { |e| e['type'] == 'bot_command' }
      end

      def start
        if current_user
          send_message 'Intro', reply_markup: { inline_keyboard: [[text: 'Book', callback_data: 'book']] }
        else
          send_message('What is your phone number?', reply_markup: { keyboard: [[{ text: 'Share my phone number', request_contact: true }]], one_time_keyboard: true, resize_keyboard: true })
        end
      end

      def book
        # Telegram.bot.answer_callback_query callback_query_id: data[:id], text: 'Text'
        send_message 'Departure address?', reply_markup: { remove_reply_keyboard: { keyboard_remove: true } }
      end

      def register
        user = User.find_or_initialize_by(phone_number: "+#{data.dig('contact', 'phone_number')}")
        user.update(telegram_username: data.dig('from', 'username'))
        send_message 'Would you like to book a taxi?', reply_markup: { inline_keyboard: [[text: 'Book', callback_data: 'book'], remove_reply_keyboard: { keyboard_remove: true }] }
      end

      def update_location
        send_message 'Demon ne vyviz?', reply_markup: { remove_keyboard: true }
      end

      def current_user
        @current_user ||= User.find_by(telegram_username: data['from']['username'])
      end

      def send_message(text, reply_markup: nil)
        Telegram.bot.send_message chat_id: chat, text: text, reply_markup: reply_markup
      end

      def chat
        @chat ||= data.dig(:chat, :id) || data.dig(:message, :chat, :id)
      end

      def trip
        @trip ||= JSON.parse(Redis.current.get("trip_#{current_user.id}"))
      end

      def trip=(attrs)
        Redis.current.set("trip_#{current_user.id}", attrs.to_json)
      end
    end
  end
end
