module Jobs
  class TelegramSendMessage < ActiveJob::Base
    def perform(chat_id, message)
      Events::Bot::SendMessage.(chat_id: chat_id, message: message)
    end
  end
end
