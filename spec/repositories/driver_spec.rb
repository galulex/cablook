describe Repositories::Driver do
  describe '#all' do
    let(:instance) { described_class.new.all }

    it { expect(instance).to be_empty }

    context 'when drivers are found' do
      let!(:driver) { Factory[:driver] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_name' do
    let(:instance) { described_class.new.by_name(name) }
    let!(:driver) { Factory[:driver] }
    let(:name) { driver.name }

    it { expect(instance.name).to eq(name) }

    context 'when driver did not found' do
      let(:name) { 'test' }

      it { expect(instance).to be nil }
    end
  end

  describe '#by_car_id' do
    let(:instance) { described_class.new.by_car_id(car_id) }
    let!(:driver) { Factory[:driver, car_id: car.id] }
    let(:car) { Factory[:car] }
    let(:car_id) { driver.car_id }

    it { expect(instance.car_id).to eq(car_id) }

    context 'when driver did not found' do
      let(:car_id) { 0 }

      it { expect(instance).to be nil }
    end
  end
end
