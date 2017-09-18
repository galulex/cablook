describe Validators::Driver do
  describe 'name must be unique' do
    subject { described_class.new(data).validate }

    let(:data) { Factory.structs[:driver] }

    it { is_expected.to be true }

    context 'when data does not have name' do
      let(:data) { { name: '' } }

      it { is_expected.to be false }
    end

    context 'when driver with this name already exist' do
      let!(:driver) { Factory[:driver] }
      let(:data) { { name: driver.name } }

      it { is_expected.to be false }
    end
  end
end
