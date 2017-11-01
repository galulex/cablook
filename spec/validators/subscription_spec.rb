describe Validators::Subscription do
  describe '#validate' do
    subject { described_class.new(data).validate }

    let(:subscription_attrs) { Factory.structs[:subscription].to_h }
    let(:data) { subscription_attrs }

    it { is_expected.to be true }

    context 'when data does not have email' do
      let(:data) { subscription_attrs.except(:email) }

      it { is_expected.to be false }
    end
  end
end
