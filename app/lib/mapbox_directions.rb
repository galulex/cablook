# class to build new trip based on coordinates through mapbox directions api
class MapboxDirections
  URL = 'https://api.mapbox.com/directions/v5/mapbox/driving/'.freeze

  attr_reader :result

  def initialize(origin, destination, waypoints = [])
    @origin = origin.split(',').reverse.join(',')
    @destination = destination.split(',').reverse.join(',')
    @waypoints = waypoints

    direction_by_coordinates
    @result = JSON.parse(Net::HTTP.get_response(URI(@url)).body)
  end

  def duration
    @result['routes'][0]['legs'].sum { |leg| leg['duration'] }
  end

  def distance
    @result['routes'][0]['legs'].sum { |leg| leg['distance'] }
  end

  def departure
    @result['waypoints'][0]['location'].reverse
  end

  def destination
    @result['waypoints'][-1]['location'].reverse
  end

  def path
    @result['routes'][0]['geometry']
  end

  def waypoints
    @result['waypoints'][1..-2].map { |leg| leg['location'].reverse.join(',') }
  end

  private

  def direction_by_coordinates
    @url = URL + @origin + ';'
    @url << @waypoints.map { |w| w.split(',').reverse.join(',') + ';' }.join('')
    @url << @destination + "?access_token=#{ENV['MAPBOX_KEY']}"
  end
end
