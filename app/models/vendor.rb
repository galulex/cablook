class Vendor < ApplicationRecord
  MAX_OPEN_TIME = '02:00'.freeze
  MAX_CLOSE_TIME = '01:59'.freeze

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

  def all_day
    open_time == MAX_OPEN_TIME && close_time == MAX_CLOSE_TIME
  end
end
