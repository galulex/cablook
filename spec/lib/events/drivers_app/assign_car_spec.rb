describe Events::DriversApp::AssignCar do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      attributes_for(:driver).merge(
        driver_id: driver.id,
        car_id: car.id
      )
    end
    let(:driver) { create(:driver) }
    let(:car) { create(:car, status: Constants::Car::OFFLINE) }

    it { is_expected.to change { driver.reload.car_id }.to(car.id) }
    it { is_expected.to change { car.reload.status }.to(Constants::Car::FREE) }

    context 'when driver_id is empty' do
      let(:data) { attributes_for(:driver).except(:driver_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when car_id is empty' do
      let(:data) { attributes_for(:driver).except(:car_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when car_id is already set' do
      let(:driver) { create(:driver, car_id: car.id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
