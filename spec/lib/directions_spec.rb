describe Directions do
  let(:directions) { Directions.new('ChIJIar5649L0UARx2zALYRK6OE', 'ChIJIar5649L0UARx2zALYRK6OE', ['ChIJ31p2iHxL0UAR6lpJx2Z3jpM', 'ChIJt5pEAO1M0UARUsVILM2BY2w']) } 
  let(:valid_response) { JSON.parse(File.read('spec/fixtures/maps/success_directions'))['routes'][0] }
  
  describe 'google directions api request' do

    describe 'request with place id' do
      it 'match json response' do
        expect(directions.result).to eq(valid_response)
      end
    end

    describe 'request with coordinates' do
      let(:directions) { Directions.new([49.4267725, 32.0533859], [49.4267725, 32.0533859], ['49.443214,32.0662627', '49.4590351,32.0335819']) } 
      
      it 'match json response' do
        expect(directions.result).to eq(valid_response)
      end
    end
    
    it 'durations should match' do 
      expect(directions.duration).to eq(valid_response['legs'].sum { |leg| leg.dig('duration', 'value') })
    end

    it 'distance shuld match' do
      expect(directions.distance).to eq(valid_response['legs'].sum { |leg| leg.dig('distance', 'value') })
    end

    it 'departures should match' do
      expect(directions.departure).to eq(valid_response['legs'][0]['start_location'].values)
    end

    it 'destinations should match' do
      expect(directions.destination).to eq(valid_response['legs'][-1]['end_location'].values)
    end

    it 'pathes should match' do
      expect(directions.path).to eq(valid_response['overview_polyline']['points'])
    end

    it 'waypoints should match' do
      expect(directions.waypoints).to eq(valid_response['legs'][0..-2].map { |leg| leg['end_location'].values.join(',') })
    end
  end
end