# https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
# params: spec/fixtures/card_callback.json

class CardCallbacksController < ActionController::Base
  def create
    Events::CreateCard.(params)
    render(
      file: Rails.public_path.join('payments', 'card_created.html'),
      content_type: 'text/html',
      status: 201
    )
  rescue Events::InvalidParamsError
    render(
      file: Rails.public_path.join('payments', 'card_failed_422.html'),
      content_type: 'text/html',
      status: 422
    )
  end
end
