describe Events::AssignCar do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      Factory.structs[:driver].to_h.merge(
        driver_id: driver.id,
        car_id: car.id
      )
    end
    let(:driver) { Factory[:driver] }
    let(:car) { Factory[:car] }

    it { is_expected.to change { drivers_repository.drivers.first } }

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
