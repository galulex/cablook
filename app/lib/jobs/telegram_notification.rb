module Jobs
  class TelegramNotification < ActiveJob::Base
    def perform(telegram_account, trip_time, items, phone_number, order_id, user_comment)
      TelegramOrder.send_order_message(telegram_account, trip_time, items, phone_number, order_id, user_comment)
    end
  end
end
