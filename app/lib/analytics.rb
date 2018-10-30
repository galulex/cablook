module Analytics
  class << self
    def run(chart_type, trip_status, from, to)
      @chart_type = chart_type
      @trip_status = trip_status
      @from = from
      @to = to

      query_parse
    end

    private

    def days
      Trip.find_by_sql("SELECT statuses.status, labels.label, COUNT(trips.id)
                        FROM (SELECT DISTINCT status FROM trips
                              WHERE trips.status IN (#{@trip_status.join(', ')})) statuses
                        CROSS JOIN (SELECT DISTINCT created_at::date AS label from trips
                                    WHERE (created_at BETWEEN '#{@from}' AND '#{@to}')) labels
                        LEFT JOIN trips on trips.status = statuses.status and trips.created_at::date = labels.label
                        GROUP BY labels.label, statuses.status
                        ORDER BY label")
    end

    def hours
      Trip.find_by_sql("SELECT statuses.status, labels.label, COUNT(trips.id)
                        FROM (SELECT DISTINCT status FROM trips
                              WHERE trips.status IN (#{@trip_status.join(', ')})) statuses
                        CROSS JOIN (SELECT DISTINCT(EXTRACT(HOUR FROM created_at AT time zone 'utc' AT TIME ZONE INTERVAL '#{Time.zone.now.formatted_offset}')) AS label FROM trips) labels
                        LEFT JOIN trips ON trips.status = statuses.status
                                        AND EXTRACT(HOUR FROM created_at AT time zone 'utc' AT TIME ZONE INTERVAL '#{Time.zone.now.formatted_offset}') = labels.label
                                        AND(created_at BETWEEN '#{@from}' AND '#{@to}')
                        GROUP BY labels.label, statuses.status
                        ORDER BY label")
    end

    def mileage
      numbers = []
      distances = []
      Trip.find_by_sql("SELECT cars.number, SUM(trips.distance / 1000) FROM cars
                   LEFT JOIN trips ON cars.id = trips.car_id AND(created_at BETWEEN '#{@from}' AND '#{@to}')
                   WHERE trips.distance > 1
                   GROUP BY cars.id
                   ORDER BY cars.id").as_json.each { |e| numbers << e['number']; distances << e['sum'] }
      { labels: numbers, datasets: [{ values: distances }] }
    end

    def by_driver
      names = []
      trips = []
      Trip.find_by_sql("SELECT drivers.name, COUNT(trips.id) FROM drivers
                        LEFT JOIN trips ON drivers.id = trips.driver_id AND(created_at BETWEEN '#{@from}' AND '#{@to}')
                        GROUP BY drivers.id
                        ORDER BY drivers.id").as_json.each { |e| names << e['name']; trips << e['count'] }
      { labels: names, datasets: [{ values: trips }] }
    end

    def query_parse
      query = send(@chart_type.to_s)
      return if query.blank?
      if query.is_a?(Hash)
        query
      else
        query = query.group_by(&:status).each_with_object([]) { |e, a| a << { name: e[0], values: e[1].map { |x| x['count'] }, labels: e[1].map { |x| x['label'] } } }
        { labels: query[0][:labels], datasets: query }
      end
    end
  end
end
