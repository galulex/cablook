module Periods
  extend ActiveSupport::Concern

  included do
    scope :this_month, -> { where('created_at BETWEEN ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month) }
    scope :last_week, ->  { where('created_at BETWEEN ? AND ?', Date.current.beginning_of_week, Date.current.end_of_week) }
    scope :last_month, -> { where('created_at BETWEEN ? AND ?', 1.month.ago.to_date.beginning_of_month, 1.month.ago.to_date.end_of_month) }
    scope :this_year, -> { where('created_at BETWEEN ? AND ?', Date.current.beginning_of_year, Date.current) }
    scope :today, -> { where('DATE(created_at) = ?', Date.today) }
    scope :last_two_days, -> { where('created_at > ?', 2.days.ago.beginning_of_day) }
  end
end
