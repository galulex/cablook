describe Events::DriversApp::Authorize do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:driver) { Factory[:driver] }
    let(:data) { { username: driver.username, password: '12341234' } }

    it { expect(result).not_to be nil }
    it { expect(result.username).to eq(driver.username) }

    context 'when username is invalid' do
      let(:data) { { username: Faker::Name.name, password: driver.encrypted_password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when password is invalid' do
      let(:data) { { username: driver.username, password: Faker::Internet.password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when car is assigned' do
      let(:car) { Factory[:car, status: Constants::Car::FREE] }
      let!(:driver) { Factory[:driver, car_id: car.id] }

      it { is_expected.to change { driver_repository.by_id(driver.id).car_id }.to(nil) }
      it { is_expected.to change { car_repository.by_id(car.id).status }.to(Constants::Car::OFFLINE) }
    end
  end
end
