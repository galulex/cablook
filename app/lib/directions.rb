# class to build new trip based on place ids instead of coordinates
class Directions
  URL = "https://maps.googleapis.com/maps/api/directions/json?key=#{ENV['GOOGLE_API_KEY']}".freeze

  attr_reader :result

  def initialize(origin, destination, waypoints = [])
    origin.is_a?(String) ? direction_by_place_id(origin, destination, waypoints) : direction_by_coordinates(origin, destination, waypoints)
    @result = JSON.parse(Net::HTTP.get_response(URI(@url)).body)['routes'][0]
  end

  def duration
    @result['legs'].sum { |leg| leg.dig('duration', 'value') }
  end

  def distance
    @result['legs'].sum { |leg| leg.dig('distance', 'value') }
  end

  def departure
    @result['legs'][0]['start_location'].values
  end

  def destination
    @result['legs'][-1]['end_location'].values
  end

  def path
    @result['overview_polyline']['points']
  end

  def waypoints
    @result['legs'][0..-2].map { |leg| leg['end_location'].values.join(',') }
  end

  private

    def direction_by_place_id(origin, destination, waypoints)
      @url = URL + "&origin=place_id:#{origin}&destination=place_id:#{destination}&waypoints="
      @url << waypoints.map { |point| "place_id:#{point}" }.join('|')
    end

    def direction_by_coordinates(origin, destination, waypoints)
      @url = URL + "&origin=#{origin[0].to_f},#{origin[1].to_f}&destination=#{destination[0].to_f},#{destination[1].to_f}&waypoints="
      @url << waypoints.map { |point| "#{point.to_f}" }.join('|') unless waypoints.nil?
    end
end
