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

    context 'cost calculation' do
      
      context 'when cents_per_km: 700' do
        before { Price.update(cents_per_km: 700) }

        it { expect(instance.cost).to eq(93) }
      end

      context 'when outside_cents_per_km: 1000' do
        before { Price.update(outside_cents_per_km: 1000) }
        
        let(:destination) { ['50.43505769999999', '32.01106010000001'] }
    
        it { expect(instance.cost).to eq(123) }
      end

      context 'when landing: 2_500' do
        
        before { Price.update(landing: 2_500) }
        
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(88) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:destination) { ['50.43505769999999', '32.01106010000001'] }
    
          it { expect(instance.cost).to eq(118) }
        end
      end
  
      context 'when coefficient: 1.5' do
        
        before { Price.update(coefficient: 1.5) }
        
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(123) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:destination) { ['50.43505769999999', '32.01106010000001'] }
    
          it { expect(instance.cost).to eq(170) }
        end
      end
  
      context 'when coefficient: 2.0' do
  
        before { Price.update(coefficient: 2.0) }
  
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(164) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:destination) { ['50.43505769999999', '32.01106010000001'] }
    
          it { expect(instance.cost).to eq(226) }
        end
      end
    end
    end
end
