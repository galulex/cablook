describe Trips do
  let(:relation) { trip_repository.trips }

  describe '#active' do
    let!(:trip_pending) { Factory[:trip, status: Constants::Trip::PENDING] }
    let!(:trip_active) { Factory[:trip, status: Constants::Trip::DRIVING] }

    let(:result) { relation.active }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_active.id) }
  end

  describe '#estimated_end_in_timeframe' do
    let!(:trip_new) { Factory[:trip, estimated_end_time: time + 5.minute] }
    let!(:trip_old) { Factory[:trip, estimated_end_time: time - 1.day] }

    let(:time) { Time.new(2017, 0o1, 0o2, 0o3, 0o4, 0o5) }
    let(:result) { relation.estimated_end_in_timeframe(time, time + 15.minutes).to_a }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_new.id) }
  end

  describe '#with_car' do
    let!(:trip_with_car) { Factory[:trip, car_id: car.id] }
    let!(:trip) { Factory[:trip, car_id: nil] }
    let(:car) { Factory[:car] }
    let(:result) { relation.with_car.to_a }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_with_car.id) }
    it { expect(result.first[:car_number]).to eq(car.number) }
  end

  describe '#with_user' do
    let!(:trip_with_user) { Factory[:trip, user_id: user.id] }
    let!(:trip) { Factory[:trip, user_id: nil] }
    let(:user) { Factory[:user] }
    let(:result) { relation.with_user.to_a }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_with_user.id) }
    it { expect(result.first[:user_number]).to eq(user.phone_number) }
    it { expect(result.first[:trips_count]).to eq(user.trips_count) }
  end
end
