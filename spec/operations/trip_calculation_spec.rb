describe Operations::TripCalculation do
  let(:instance) { described_class.new(departure: departure, destination: destination) }
  let(:departure) { ['49.43505769999999', '32.01106010000001'] }
  let(:destination) { ['49.443102', '32.063407'] }

  describe '#cost' do
    before { allow_any_instance_of(SearchEngine::Directions).to receive(:distance) { 10_000 } }

    context 'when strategy is city' do
      it { expect(instance.cost).to eq(82) }
    end

    context 'when the strategy is out-of-town' do
      let(:destination) { ['50.43505769999999', '32.01106010000001'] }

      it { expect(instance.cost).to eq(113) }
    end

    context 'when points is the hotel ukraina' do
      let(:destination) { ['49.477132', '31.995375'] }

      it { expect(instance.cost).to eq(82) }
    end
  end
end
