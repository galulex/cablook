describe Events::CreateSubscription do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:subscription].to_h }

    it { is_expected.to change { subscriptions_repository.subscriptions.count }.by(+1) }

    context 'when email is empty' do
      let(:data) { Factory.structs[:subscription].to_h.except(:email) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
