module Api
  class WebhooksController < ApiApplicationController
    def update
      Events::Bot::Reply.(params['message'] || params['callback_query'])

      head 200
    end
  end
end
