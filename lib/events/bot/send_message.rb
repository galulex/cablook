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
        Telegram.bot.send_message(chat_id: data[:chat_id], text: data[:message], parse_mode: 'Markdown')
        Telegram.bot.send_location(chat_id: data[:chat_id], latitude: data[:location][0], longitude: data[:location][1]) if data[:location]
      end
    end
  end
end
