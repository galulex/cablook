describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }

  let(:connection) { TestConnection.new }

  let(:car_id) { 0 }
  let(:latitude) { Faker::Address.latitude }
  let(:latitude) { Faker::Address.longitude }
  let(:longitude) { 14.88 }
  let(:data) do
    {
      'action' => 'send_location',
      'body' => {
        'latitude': latitude,
        'longitude': longitude,
        'car_id': car_id
      }.to_json
    }
  end

  let(:redis_car_location) { Redis.new.get("car_#{car_id}") }

  before { channel.perform_action(data) }

  it { expect(redis_car_location).to eq([latitude, longitude].to_s) }
end
