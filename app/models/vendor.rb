class Vendor < ApplicationRecord
  has_many :orders, dependent: :nullify

  scope :visible, -> { where(active: true) }

  def open_now?
    Time.now.hour.between?(open_at.hour, close_at.hour)
  end

  def status
    open_now? ? :open : :close
  end

  def open_time
    open_at.strftime('%H:%M')
  end

  def close_time
    close_at.strftime('%H:%M')
  end

  def name_slug
    name.parameterize
  end
end
