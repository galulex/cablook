describe Operations::V2TripCalculation do
  let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['49.443102', '32.063407'], distance: 10_000) }
  let(:instance) { described_class.new(trip) }

  describe '#cost' do

    context 'when strategy is city' do
      it { expect(instance.cost).to eq(82) }
    end

    context 'when the strategy is out-of-town' do
      let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['50.43505769999999', '32.01106010000001'], distance: 10_000) }

      it { expect(instance.cost).to eq(113) }
    end

    context 'when points is the hotel ukraina' do
      let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['49.4761084', '31.99678949999999'], distance: 10_000) }

      it { expect(instance.cost).to eq(82) }
    end

    context 'cost calculation' do
      
      context 'when cents_per_km: 700' do
        before { Price.update(cents_per_km: 700) }

        it { expect(instance.cost).to eq(93) }
      end

      context 'when outside_cents_per_km: 1000' do
        before { Price.update(outside_cents_per_km: 1000) }

        let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['50.43505769999999', '32.01106010000001'], distance: 10_000) }
    
        it { expect(instance.cost).to eq(123) }
      end

      context 'when landing: 2_500' do
        
        before { Price.update(landing: 2_500) }
        
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(88) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['50.43505769999999', '32.01106010000001'], distance: 10_000) }
    
          it { expect(instance.cost).to eq(118) }
        end
      end
  
      context 'when coefficient: 1.5' do
        
        before { Price.update(coefficient: 1.5) }
        
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(123) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['50.43505769999999', '32.01106010000001'], distance: 10_000) }
    
          it { expect(instance.cost).to eq(170) }
        end
      end
  
      context 'when coefficient: 2.0' do
  
        before { Price.update(coefficient: 2.0) }
  
        context 'and strategy is city' do
          it { expect(instance.cost).to eq(164) }
        end
    
        context 'and the strategy is out-of-town' do
          let(:trip) { create(:trip, departure: ['49.43505769999999', '32.01106010000001'], destination: ['50.43505769999999', '32.01106010000001'], distance: 10_000) }
    
          it { expect(instance.cost).to eq(226) }
        end
      end
    end
  end
end
