describe Events::Trips::Accept do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:driver) { create(:driver, car_id: create(:car).id) }
    let(:trip) { create(:trip, user_id: user.id) }
    let(:user) { create(:user) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let!(:device) { create(:device, user_id: user.id) }
    let(:data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }
    let(:car) { create(:car) }

    before { Redis.current.set("car_#{driver.car_id}", '49.437559,32.1004251') }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::ON_THE_WAY]) }
    it { is_expected.to change { trip.reload.car_id }.to(driver.car_id) }
    it { is_expected.to change { trip.reload.driver_id}.to(driver.id) }
    it { is_expected.to change { driver.car.reload.status }.to('during_trip') }

    context 'when trip was accepted' do
      let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY, user_id: user.id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end

    context 'when trip pre-ordered' do
      let(:trip) { create(:trip, user_id: user.id, driver_id: driver.id, preorder_time: 2.hours.since) }

      it { is_expected.not_to change { car.reload.status } }
      it { expect(trip.reload.start_at.strftime('%H:%M')).to eq(2.hours.since.strftime('%H:%M')) }
    end

    context 'time calculation' do
      let(:driver) { create(:driver, car_id: car.id) }
      let(:trip) { create(:trip, user_id: user.id, car_id: car.id) }

      before { allow_any_instance_of(OsrmDirections).to receive(:duration).and_return(300) }

      context 'when free driver accept trip' do
        it { is_expected.to change { trip.reload.start_at.to_s }.to(7.minutes.since.to_s) }
      end

      context 'when driver accept second trip' do
        let(:data) { { trip_id: first_trip.id, driver_id: driver.id, car_id: driver.car_id } }
        let!(:payment) { create(:payment, trip_id: first_trip.id, user_id: user.id) }
        let(:new_data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }

        before(:each) { described_class.call(new_data) }

        context 'and have pre-ordered trip' do
          let!(:first_trip) { create(:trip, duration: 10.minutes, status: Constants::Trip::ON_THE_WAY, preorder_time: 2.hours.since, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.to_s).to eq(7.minutes.since.to_s) }
        end

        context 'during first trip' do
          let!(:first_trip) { create(:trip, started_at: 8.minutes.ago, duration: 10.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.to_s).to eq(9.minutes.since.to_s) }
        end

        context 'but forgot finish first trip' do
          let!(:first_trip) { create(:trip, started_at: 20.minutes.ago, duration: 10.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.to_s).to eq(7.minutes.since.to_s) }
        end

        context 'on the way to the first trip' do
          let!(:first_trip) { create(:trip, start_at: 5.minutes.since, duration: 10.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(22.minutes.since.change(sec: 0).to_s) }
        end

        context 'during waiting client' do
          let!(:first_trip) { create(:trip, start_at: Time.now, duration: 10.minutes, status: Constants::Trip::WAITING_CLIENT, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.to_s).to eq(17.minutes.since.to_s) }
        end
      end

      context 'when driver accept third trip' do
        let(:data) { { trip_id: first_trip.id, driver_id: driver.id, car_id: driver.car_id } }
        let(:data_2) { { trip_id: second_trip.id, driver_id: driver.id, car_id: driver.car_id } }
        let!(:payment) { create(:payment, trip_id: second_trip.id, user_id: user.id) }
        let(:new_data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }

        before(:each) { described_class.call(new_data) }

        context 'and have pre-ordered trip' do
          let!(:first_trip) { create(:trip, duration: 10.minutes, status: Constants::Trip::ON_THE_WAY, preorder_time: 2.hours.since, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, duration: 5.minutes, start_at: 8.minutes.since, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(20.minutes.since.change(sec: 0).to_s) }
        end

        context 'during first trip' do
          let!(:first_trip) { create(:trip, started_at: 8.minutes.ago, duration: 10.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, start_at: 13.minutes.since, duration: 5.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(25.minutes.since.change(sec: 0).to_s) }
        end

        context 'but forgot finish first trip & during second trip' do
          let!(:first_trip) { create(:trip, started_at: 20.minutes.ago, duration: 10.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, started_at: 5.minutes.ago, duration: 10.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(12.minutes.since.change(sec: 0).to_s) }
        end

        context 'but forgot finish first & second trips' do
          let!(:first_trip) { create(:trip, started_at: 20.minutes.ago, duration: 10.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, started_at: 10.minutes.ago, duration: 5.minutes, status: Constants::Trip::DRIVING, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(7.minutes.since.change(sec: 0).to_s) }
        end

        context 'on the way to the first trip' do
          let!(:first_trip) { create(:trip, start_at: 5.minutes.since, duration: 10.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, start_at: 10.minutes.since, duration: 8.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(25.minutes.since.change(sec: 0).to_s) }
        end

        context 'during waiting client for first trip' do
          let!(:first_trip) { create(:trip, start_at: Time.now, duration: 10.minutes, status: Constants::Trip::WAITING_CLIENT, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, started_at: 8.minutes.since, duration: 5.minutes, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(20.minutes.since.change(sec: 0).to_s) }
        end

        context 'during waiting client for second trip' do
          let!(:first_trip) { create(:trip, started_at: 20.minutes.ago, duration: 10.minutes, status: Constants::Trip::FINISHED, car_id: car.id, driver_id: driver.id) }
          let!(:second_trip) { create(:trip, start_at: Time.now, duration: 5.minutes, status: Constants::Trip::WAITING_CLIENT, car_id: car.id, driver_id: driver.id) }

          it { expect(trip.reload.start_at.change(sec: 0).to_s).to eq(12.minutes.since.change(sec: 0).to_s) }
        end
      end
    end
  end
end
