describe Cars do
  let(:relation) { car_repository.cars }

  describe '#with_driver' do
    let!(:car) { Factory[:car] }
    let(:car_with_driver) { Factory[:car] }
    let!(:driver) { Factory[:driver, car_id: car_with_driver.id] }
    let(:result) { relation.with_driver.to_a }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(car_with_driver.id) }
    it { expect(result.first[:driver_id]).to eq(driver.id) }
  end
end
