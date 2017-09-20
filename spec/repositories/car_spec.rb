describe Repositories::Car do
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
