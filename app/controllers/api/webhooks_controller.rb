module Api
  class WebhooksController < ApiApplicationController
    def update
      Events::Bot::Reply.(params['message'].merge(cards_url: new_card_url) || params['callback_query'])
      head 200
    end
  end
end
