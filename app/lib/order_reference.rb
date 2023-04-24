class OrderReference
  def initialize(trip_id, payment_type = 'trip')
    @trip_id = trip_id
    @payment_type = payment_type
  end

  def call
    "cablook_#{dev_prefix}#{trip_id}_payments_#{payment_type}_#{secure_code}"
  end

  private

  attr_reader :trip_id, :payment_type

  def secure_code
    SecureRandom.base58(6)
  end

  def dev_prefix
    return if Rails.env.production?

    "#{Rails.env}_"
  end
end
