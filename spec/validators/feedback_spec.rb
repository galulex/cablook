describe Validators::Feedback do
  describe '#validate' do
    subject { described_class.new(data).validate }

    let(:trip_attrs) { Factory.structs[:feedback, user_id: 1, trip_id: 1].to_h }
    let(:data) { trip_attrs }

    it { is_expected.to be true }

    context 'when data does not have rate' do
      let(:data) { trip_attrs.except(:rate) }

      it { is_expected.to be false }
    end

    context 'when data does not have trip_id' do
      let(:data) { trip_attrs.except(:trip_id) }

      it { is_expected.to be false }
    end

    context 'when data does not have user_id' do
      let(:data) { trip_attrs.except(:user_id) }

      it { is_expected.to be false }
    end
  end
end
