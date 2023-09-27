module Api
  class WebhooksController < ApiApplicationController
    def update
      reply
      head 200
    end

    private

    def reply
      Events::Bot::Reply.(reply_params.permit!) if params.dig('message', 'chat', 'type') == 'private' || params.dig('callback_query', 'message', 'chat', 'type') == 'private'
    end

    def reply_params
      params['message'] ? params['message'].merge(cards_url: new_card_url) || params['callback_query'] : params['callback_query']
    end
  end
end
