class UserTelegram < ApplicationRecord
  belongs_to :user
  has_many :cards, through: :user
  delegate :auth_token, to: :user

  def reply(action, message, attrs = {})
    telegram_msg = telegram_message(message, attrs[:message_options])
    Telegram.bot.send(action, telegram_msg.merge(chat_id: chat_id).merge(attrs))
  end

  private

  def telegram_message(message, options = {})
    return I18n.t("bot.#{message}") unless options.present?
    telegram_text(message, options).merge(telegram_caption(message, options))
  end

  def telegram_text(message, options = {})
    { text: I18n.t("bot.#{message}.text", options) }
  end

  def telegram_caption(message, options = {})
    { caption: I18n.t("bot.#{message}.caption", options) }
  end
end
