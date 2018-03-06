describe Events::DriversApp::SignOut do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:driver) { Factory[:driver, car_id: car.id] }
    let(:car) { Factory[:car] }
    let(:data) { { driver_id: driver.id } }

    it { is_expected.to change { driver_repository.by_id(driver.id).auth_token }.from(driver.auth_token) }
    it { is_expected.to change { driver_repository.by_id(driver.id).car_id }.from(car.id).to(nil) }
    it { is_expected.to change { car_repository.by_id(car.id).status }.to(Constants::Car::OFFLINE) }

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
