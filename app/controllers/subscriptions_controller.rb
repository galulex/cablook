class SubscriptionsController < ApplicationController
  def create
    Events::CreateSubscription.(subscription_params)
  end

  private

  def subscription_params
    params.fetch(:subscription, {}).permit(:email)
  end
end
