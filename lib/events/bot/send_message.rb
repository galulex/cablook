module Events
  module Bot
    class SendMessage < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:chat_id).filled(:str?)
          required(:message).filled(:str?)
        end
      end

      def run
        Telegram.bot.send_message(chat_id: data[:chat_id], text: data[:message])
      end
    end
  end
end