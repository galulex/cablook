class BusinessPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/notifier/welcome
  def receipt
    BusinessMailer.receipt(Business.first, Trip.last)
  end
end
