describe Trips do
  let(:relation) { Repositories::Trip.new.trips }

  context '#active' do
    let!(:trip_pending) { Factory[:trip, status: Constants::Trip::PENDING] }
    let!(:trip_active) { Factory[:trip, status: Constants::Trip::DRIVING] }

    let(:result) { relation.active }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_active.id) }
  end

  context '#estimated_end_in_timeframe' do
    let!(:trip_new) { Factory[:trip, estimated_end_time: time + 5.minute] }
    let!(:trip_old) { Factory[:trip, estimated_end_time: time - 1.day] }

    let(:time) { Time.new(2017, 0o1, 0o2, 0o3, 0o4, 0o5) }
    let(:result) { relation.estimated_end_in_timeframe(time, time + 15.minutes).to_a }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_new.id) }
  end
end
