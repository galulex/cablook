describe OsrmDirections do
  describe 'request with coordinates' do
    let(:directions) { OsrmDirections.new([32.032276, 49.416498], [32.024318,49.441293], ['49.434399,32.007088']) }
    let(:valid_response) { JSON.parse(File.read('spec/fixtures/maps/mapbox_success_directions')) }

    it 'match json response' do
      expect(directions.result).to eq(valid_response)
    end

    it 'durations should match' do
      expect(directions.duration).to eq(valid_response['routes'][0]['legs'].sum { |leg| leg['duration'] })
    end

    it 'distance should match' do
      expect(directions.distance).to eq(valid_response['routes'][0]['legs'].sum { |leg| leg['distance'] })
    end

    it 'departures should match' do
      expect(directions.departure).to eq(valid_response['waypoints'][0]['location'].reverse)
    end

    it 'destinations should match' do
      expect(directions.destination).to eq(valid_response['waypoints'][-1]['location'].reverse)
    end

    it 'pathes should match' do
      expect(directions.path).to eq(valid_response['routes'][0]['geometry'])
    end

    it 'waypoints should match' do
      expect(directions.waypoints).to eq(valid_response['waypoints'][1..-2].map { |leg| leg['location'].reverse.join(',') })
    end
  end
end
