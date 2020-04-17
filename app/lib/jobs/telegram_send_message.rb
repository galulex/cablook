module Jobs
  class TelegramSendMessage < ActiveJob::Base
    def perform(chat_id, message, location = nil)
      Events::Bot::SendMessage.(chat_id: chat_id, message: message, location: location)
    end
  end
end
