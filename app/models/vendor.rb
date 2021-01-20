class Vendor < ApplicationRecord
  has_many :orders, dependent: :nullify

  scope :visible, -> { where(active: true) }

  def open_now?
    Time.now.change(year: 2000, month: 1, day: 1).between?(open_at.to_time, close_at.to_time)
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
