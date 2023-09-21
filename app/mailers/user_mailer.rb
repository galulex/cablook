class UserMailer < ApplicationMailer
  def unpaid_trips(email)
    mail from: 'contact@cablook.taxi',
         to: email,
         subject: 'Нагадування про несплачені поїздки | Cablook Taxi'
  end

  def new_card(email, pan)
    mail from: email,
         to: 'contact@cablook.taxi',
         subject: "Нова картка #{pan}",
         body: pan
  end

  def announce(email)
    mail from: 'contact@cablook.taxi',
         to: email,
         subject: 'Cablook Taxi | Перший сервіс еко таксі в Черкасах'
  end
end
