class ConvertTipsToPayments < ActiveRecord::Migration[5.2]
  def change
    Tip.find_each do |tip|
      Payments::Tip.create(
        trip_id: tip.trip_id,
        user_id: tip.trip.user_id,
        amount: tip.amount,
        response: tip.response,
        status: Constants::Payments::SUCCESS
      )
    end
    drop_table :tips
  end
end
