module Api
  class WebhooksController < ApiApplicationController
    def update
      Events::Bot::Reply.(params['message'] || params['callback_query'])
    ensure
      head 200
    end
  end
end
