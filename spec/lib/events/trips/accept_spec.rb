describe Events::Trips::Accept do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:driver) { Factory[:driver, car_id: Factory[:car].id] }
    let(:trip) { Factory[:trip, user_id: user.id] }
    let(:user) { Factory[:user] }
    let!(:payment) { Factory[:payment, trip_id: trip.id]}
    let!(:device) { Factory[:device, user_id: user.id] }
    let(:data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }


    before do
      Redis.current.set("car_#{driver.car_id}", '49.461655,32.165358')
    end

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::ON_THE_WAY) }
    it { is_expected.to change { trip_repository.by_id(trip.id).car_id }.to(driver.car_id) }
    it { is_expected.to change { trip_repository.by_id(trip.id).driver_id}.to(driver.id) }
    it { is_expected.to change { car_repository.by_id(driver.car_id).status }.to(Constants::Car::DURING_IN_TRIP) }
    it { is_expected.not_to have_enqueued_job(Jobs::Sms) }

    context 'when trip was accepted' do
      let(:trip) { Factory[:trip, status: Constants::Trip::ON_THE_WAY, user_id: user.id] }

      it { is_expected.not_to change { trip_repository.by_id(trip.id).status } }

      context 'and broadcast to channel' do
        after { subject.call }

        it { expect(ActionCable.server).to receive(:broadcast).once }
      end
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end
  end
end
