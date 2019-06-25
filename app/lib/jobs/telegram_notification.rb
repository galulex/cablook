module Jobs
  class TelegramNotification < ActiveJob::Base
    def perform(telegram_account, trip_time, items, phone_number, order_id)
      TelegramOrder.send_order_message(telegram_account, trip_time, items, phone_number, order_id)
    end
  end
end

