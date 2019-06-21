module Jobs
  class TelegramNotification < ActiveJob::Base
    def perform(telegram_account, trip_time, items, phone_number)
      TelegramOrder.send_order_message(telegram_account, trip_time, items, phone_number)
    end
  end
end

