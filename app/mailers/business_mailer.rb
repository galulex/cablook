class BusinessMailer < ApplicationMailer
  def receipt(trip)
    @email = trip.card.business.email
    @trip = trip
    mail to: @email
  end
end
