class UserMailer < ApplicationMailer
  def unpaid_trips(email)
    mail from: 'contact@cablook.taxi',
         to: email,
         subject: 'Нагадування про несплачені поїздки | Cablook Taxi'
  end

  def new_card(email, pan)
    mail from: 'contact@cablook.taxi',
         to: email,
         subject: "Нова картка #{pan}",
         body: pan
  end
end
