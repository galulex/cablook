describe Repositories::Car do
  describe '#all' do
    let(:instance) { cars_repository.all }

    it { expect(instance).to be_empty }

    context 'when cars are found' do
      let!(:car) { Factory[:car] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_number' do
    let(:instance) { cars_repository.by_number(number) }
    let!(:car) { Factory[:car] }
    let(:number) { car.number }

    it { expect(car.number).to eq(number) }

    context 'when car did not found' do
      let(:number) { '1111' }

      it { expect(instance).to be nil }
    end
  end

  describe '#free_cars' do
    subject { cars_repository.free_cars }

    context 'when there are free cars' do
      let!(:car) { Factory[:car, status: 0] }

      it { is_expected.not_to be_empty }
    end

    context 'when there are no free cars' do
      let!(:car) { Factory[:car, status: 1] }

      it { is_expected.to be_empty }
    end
  end
end
