module Api
  class WebhooksController < ApiApplicationController
    def update
      reply
      head 200
    end

    private

    def reply
      Events::Bot::Reply.(reply_params) if params.dig('message', 'data') || params.dig('message', 'entities') && params.dig('message', 'entities')[0].dig('type') == 'bot_command'
    end

    def reply_params
      params['message'] ? params['message'].merge(cards_url: new_card_url) || params['callback_query'] : params['callback_query']
    end
  end
end
