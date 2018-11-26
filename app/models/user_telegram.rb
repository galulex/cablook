class UserTelegram < ApplicationRecord
  belongs_to :user

  def reply(action, message, attrs = {})
    Telegram.bot.send(action, I18n.t("bot.#{message}").merge(chat_id: chat_id).merge(attrs))
  end
end
