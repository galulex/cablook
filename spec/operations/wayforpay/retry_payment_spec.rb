describe Operations::Wayforpay::RetryPayment do
  let(:instance) { described_class.new(payment.id, card.id) }
  let(:user) { Factory[:user] }
  let(:card) { Factory[:card, user_id: user.id] }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { Factory[:payment, user_id: user.id, status: Constants::Payments::PENDING] }

    it do
      expect(Wayforpay::Payments).to receive(:hold).once
      subject.call
    end
    it { is_expected.to change { payment_repository.by_id(payment.id).status }.to(Constants::Payments::SUCCESS) }

    context 'when smth went wrong from wayforpay' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      it { is_expected.not_to change { payment_repository.by_id(payment.id).status } }
      it { is_expected.to change { payment_repository.by_id(payment.id).response }.to(JSON.parse(wayforpay_body)) }
    end
  end
end
