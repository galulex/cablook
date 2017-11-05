class SubscriptionsController < ApplicationController
  def create
    validator = Validators::Subscription.new(subscription_params)
    if validator.valid?
      Repositories::Subscription.new(ROM.env).create(subscription_params)
      redirect_to '/?submit=true'
    else
      redirect_to '/'
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email).merge(created_at: Time.now).to_h
  end
end
