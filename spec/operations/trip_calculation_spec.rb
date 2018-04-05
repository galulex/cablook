describe Operations::TripCalculation do
  let(:instance) { described_class.new(departure: departure, destination: destination) }
  let(:departure) { ['49.43505769999999', '32.01106010000001'] }
  let(:destination) { ['50.43505769999999', '32.01106010000001'] }

  describe '#cost' do
    before { allow_any_instance_of(SearchEngine::Directions).to receive(:distance) { 10_000 } }

    context 'when strategy is city' do
      it { expect(instance.cost).to eq(82) }
    end

    context 'when the strategy is out-of-town' do
      # TODO
    end
  end
end
