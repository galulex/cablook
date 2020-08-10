module Events
  module Bot
    class SendMessage < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:chat_id).filled(:str?)
          required(:message).filled(:str?)
          required(:location).filled { each(:float?) }
        end
      end

      def run
        chat_id = data[:chat_id]
        location = data[:location]
        message = data[:message]
        bot = Telegram.bot
        bot.send_message(chat_id: chat_id, text: message, parse_mode: 'Markdown')
        bot.send_location(chat_id: chat_id, latitude: location[0], longitude: location[1])
      rescue Telegram::Bot::Error => error
        Jobs::TelegramSendMessage.set(wait: 1.minute).perform_later(chat_id, message, location)
      end
    end
  end
end
