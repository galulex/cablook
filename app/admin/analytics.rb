ActiveAdmin.register_page 'Analytics' do
  content do
    render 'index'
  end

  controller do
    def index
      @trips = chart_type
    end
  end
end

def chart_type
  case params[:type]
  when 'days'
    count_by_days
  when 'hours'
    count_by_hours
  else
    count_by_days
  end
end

def count_by_days
  Trip.find_by_sql("SELECT statuses.status, days.day, COUNT(trips.id)
                    FROM (SELECT DISTINCT status FROM trips
                          WHERE trips.status IN (#{trip_status.join(', ')})) statuses
                    CROSS JOIN (SELECT DISTINCT created_at::date AS day from trips
                                WHERE (created_at BETWEEN '#{from}' AND '#{to}')) days
                    LEFT JOIN trips on trips.status = statuses.status and trips.created_at::date = days.day
                    GROUP BY days.day, statuses.status
                    ORDER BY day")
      .group_by(&:status)
      .each_with_object([]) { |e, a| a << { name: e[0], values: e[1].map { |x| x['count'] }, days: e[1].map { |x| x['day'] } } }.as_json
end

def count_by_hours
  Trip.find_by_sql("SELECT statuses.status, hours.hour, COUNT(trips.id)
                    FROM (SELECT DISTINCT status FROM trips
                          WHERE trips.status IN (#{trip_status.join(', ')})) statuses
                    CROSS JOIN (SELECT EXTRACT(HOUR FROM created_at) AS hour FROM trips
                                WHERE (created_at BETWEEN '#{from}' AND '#{to}')) hours
                    LEFT JOIN trips on trips.status = statuses.status and EXTRACT(HOUR FROM created_at) = hours.hour
                    GROUP BY hours.hour, statuses.status
                    ORDER BY hour")
      .group_by(&:status)
      .each_with_object([]) { |e, a| a << { name: e[0], values: e[1].map { |x| x['count'] }, hours: e[1].map { |x| x['hour'] } } }.as_json
end

def from
  params[:from].blank? ? Time.now.beginning_of_day.strftime('%F') : params[:from]
end

def to
  params[:to].blank? ? Time.now.end_of_day.strftime('%F') : params[:to]
end

def trip_status
  params[:status].blank? ? (4..7).to_a : params[:status]
end
