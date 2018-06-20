describe Events::DriversApp::SignOut do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:driver) { create(:driver, car_id: car.id) }
    let(:car) { create(:car) }
    let(:data) { { driver_id: driver.id } }

    it { is_expected.to change { driver.reload.auth_token }.from(driver.auth_token) }
    it { is_expected.to change { driver.reload.car_id }.from(car.id).to(nil) }
    it { is_expected.to change { car.reload.status }.to(Constants::Car::OFFLINE) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::DRIVER_SIGN_OUT,
          driver_id: driver.id,
          car_id: car.id
        ).once
        subject.call
      end
    end
  end
end
