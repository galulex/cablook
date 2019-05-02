class DriverRequestsController < ApplicationController
  def create
    AdminMailer.new_driver_request(params[:cv]).deliver_now
  end
end