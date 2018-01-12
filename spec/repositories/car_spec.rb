describe Repositories::Car do
  describe '#all' do
    let(:instance) { car_repository.all }

    it { expect(instance).to be_empty }

    context 'when cars are found' do
      let!(:car) { Factory[:car] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_number' do
    let(:instance) { car_repository.by_number(number) }
    let!(:car) { Factory[:car] }
    let(:number) { car.number }

    it { expect(car.number).to eq(number) }

    context 'when car did not found' do
      let(:number) { '1111' }

      it { expect(instance).to be nil }
    end
  end

  describe '#free_cars' do
    subject { car_repository.free_cars }

    context 'when free car with driver' do
      let(:car) { Factory[:car, status: Constants::Car::FREE] }
      let!(:driver) { Factory[:driver, car_id: car.id] }

      it { is_expected.not_to be_empty }
    end

    context 'when free car without driver' do
      let!(:car) { Factory[:car, status: Constants::Car::FREE] }

      it { is_expected.to be_empty }
    end

    context 'when there are no free cars' do
      let!(:car) { Factory[:car, status: Constants::Car::OFFLINE] }

      it { is_expected.to be_empty }
    end
  end

  describe '#offline' do
    subject { car_repository.offline }

    context 'when there are free cars' do
      let!(:car) { Factory[:car, status: Constants::Car::OFFLINE] }

      it { is_expected.not_to be_empty }
    end

    context 'when there are no free cars' do
      let!(:car) { Factory[:car, status: Constants::Car::FREE] }

      it { is_expected.to be_empty }
    end
  end

  describe '#online' do
    subject { car_repository.online.count }

    context 'when only offline cars' do
      before do
        Factory[:car, status: Constants::Car::OFFLINE]
        Factory[:car, status: Constants::Car::OFFLINE]
      end

      it { is_expected.to eq(0) }
    end

    context 'when there are free cars' do
      before do
        Factory[:car, status: Constants::Car::OFFLINE]
        Factory[:car, status: Constants::Car::FREE]
      end

      it { is_expected.to eq(1) }
    end

    context 'and during in a trip cars consist' do
      before do
        Factory[:car, status: Constants::Car::FREE]
        Factory[:car, status: Constants::Car::DURING_IN_TRIP]
      end

      it { is_expected.to eq(2) }
    end

    context 'and cars in charging consist' do
      before do
        Factory[:car, status: Constants::Car::FREE]
        Factory[:car, status: Constants::Car::CHARGE]
      end

      it { is_expected.to eq(2) }
    end
  end
end
