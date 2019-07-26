class UserMailer < ApplicationMailer
  def unpaid_trips(email)
    mail from: 'contact@cablook.taxi',
         to: email,
         subject: 'Нагадування про несплачені поїздки | Cablook Taxi'
  end
end
