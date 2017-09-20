describe Repositories::Driver do
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
end
