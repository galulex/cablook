class Presenters::Trips::StatsSingle < Presenters::BaseSingle
  properties :id, :status, :cost, :duration, :distance, :stops, :vip
  property :start_time, exec_context: :decorator
  property :finish_time, exec_context: :decorator
  property :payment_method, exec_context: :decorator

  def payment_method
    represented.trip_payment&.payment_method
  end

  def start_time
    represented.start_at.strftime('%d/%m') > Time.now.strftime('%d/%m') ? represented.start_at.strftime('%d/%m, %H:%M') : represented.start_at.strftime('%H:%M')
  rescue
    nil
  end

  def finish_time
    (represented.start_at + represented.duration.seconds).strftime('%H:%M')
  rescue
    nil
  end
end
