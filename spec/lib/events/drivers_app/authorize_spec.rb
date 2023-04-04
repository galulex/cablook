describe Events::DriversApp::Authorize do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:driver) { create(:driver_with_car) }
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

    context 'when car is not assigned' do
      let(:driver) { create(:driver) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when driver login successful' do
      it { is_expected.to change { driver.car.reload.status }.to(Constants::Car::STATUS_CODES[Constants::Car::FREE]) }
      it { is_expected.to change { driver.reload.auth_token } }
    end

    context 'when driver login successful and have active trip' do
      let!(:trip) { create(:trip, car: driver.car) }

      it { is_expected.to change { driver.car.reload.status }.to(Constants::Car::STATUS_CODES[Constants::Car::DURING_TRIP]) }
    end
  end
end
