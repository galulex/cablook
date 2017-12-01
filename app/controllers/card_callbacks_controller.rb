# https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
# params: spec/fixtures/card_callback.json

class CardCallbacksController < ApplicationController
  def create
    Events::CreateCard.(params)
    render file: Rails.public_path.join('templates', 'payments', 'card_created.html'), layout: true # /public/templates/home.html

  rescue Events::InvalidParamsError
  end
end
