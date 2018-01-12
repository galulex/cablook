describe Events::DriversApp::AssignCar do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      Factory.structs[:driver].to_h.merge(
        driver_id: driver.id,
        car_id: car.id
      )
    end
    let(:driver) { Factory[:driver] }
    let(:car) { Factory[:car, status: Constants::Car::OFFLINE] }

    it { is_expected.to change { driver_repository.by_id(driver.id).car_id }.to(car.id) }
    it { is_expected.to change { car_repository.by_id(car.id).status }.to(Constants::Car::FREE) }

    context 'when driver_id is empty' do
      let(:data) { Factory.structs[:driver].to_h.except(:driver_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when car_id is empty' do
      let(:data) { Factory.structs[:driver].to_h.except(:car_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when car_id is already set' do
      let(:driver) { Factory[:driver, car_id: car.id] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
