describe Repositories::Car do
  describe '#all' do
    let(:instance) { described_class.new.all }

    it { expect(instance).to be_empty }

    context 'when cars are found' do
      let!(:car) { Factory[:car] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_number' do
    let(:instance) { described_class.new.by_number(number) }
    let!(:car) { Factory[:car] }
    let(:number) { car.number }

    it { expect(car.number).to eq(number) }

    context 'when car did not found' do
      let(:number) { '1111' }

      it { expect(instance).to be nil }
    end
  end
end
