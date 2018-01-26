describe TripChannel do
  let(:channel) { described_class.new(connection, nil, trip_id: trip.id) }
  let(:connection) { TestConnection.new }
  let!(:trip) { Factory[:trip] }

  context '#start_trip' do
    let(:data) do
      {
        'action' => 'start_trip',
        'body' => {
          'estimated_end_time' => Time.now + 10.minutes
        }.to_json
      }
    end

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::DRIVING) }
    it { is_expected.to change { trip_repository.by_id(trip.id).started_at }.from(nil) }
  end

  context '#finish_trip' do
    let(:data) { { 'action' => 'finish_trip' } }

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::FINISHED) }
    it { is_expected.to change { trip_repository.by_id(trip.id).finished_at }.from(nil) }
  end

  context '#waiting_client' do
    let(:data) { { 'action' => 'waiting_client' } }

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::WAITING_CLIENT) }
    it { is_expected.to change { trip_repository.by_id(trip.id).arrived_at }.from(nil) }
  end
end
