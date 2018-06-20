describe Events::Trips::Accept do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:driver) { create(:driver, car_id: create(:car).id) }
    let(:trip) { create(:trip, user_id: user.id) }
    let(:user) { create(:user) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let!(:device) { create(:device, user_id: user.id) }
    let(:data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }


    before { Redis.current.set("car_#{driver.car_id}", '49.461655,32.165358') }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::ON_THE_WAY]) }
    it { is_expected.to change { trip.reload.car_id }.to(driver.car_id) }
    it { is_expected.to change { trip.reload.driver_id}.to(driver.id) }
    it { is_expected.to change { driver.car.reload.status }.to(Constants::Car::DURING_IN_TRIP) }
    it { is_expected.not_to have_enqueued_job(Jobs::Sms) }

    context 'when trip was accepted' do
      let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY, user_id: user.id) }

      it { is_expected.not_to change { trip.reload.status } }

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
