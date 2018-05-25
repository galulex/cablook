class BusinessMailer < ApplicationMailer
  def receipt(business, trip)
    @email = business.email
    @trip = trip
    mail to: @email
  end
end
