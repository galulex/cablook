describe Validators::Trip do
  describe '#validate' do
    subject { described_class.new(data).validate }

    let(:trip_attrs) { Factory.structs[:trip, user_id: 1].to_h }
    let(:data) { trip_attrs }

    it { is_expected.to be true }

    context 'when data does not have path' do
      let(:data) { trip_attrs.except(:path) }

      it { is_expected.to be false }
    end

    context 'when data does not have cost' do
      let(:data) { trip_attrs.except(:cost) }

      it { is_expected.to be false }
    end

    context 'when data does not have user_id' do
      let(:data) { trip_attrs.except(:user_id) }

      it { is_expected.to be false }
    end
  end
end
