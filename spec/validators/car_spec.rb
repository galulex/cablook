describe Validators::Car do
  describe 'number must be unique' do
    subject { described_class.new(data).validate }

    let(:data) { Factory.structs[:car] }

    it { is_expected.to be true }

    context 'when data does not have number' do
      let(:data) { Factory.structs[:car].to_h.except(:number) }

      it { is_expected.to be false }
    end

    context 'when car with this number already exists' do
      let!(:car) { Factory[:car] }
      let(:data) { { number: car.number } }

      it { is_expected.to be false }
    end
  end
end
