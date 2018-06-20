describe Operations::Wayforpay::RetryPayment do
  let(:instance) { described_class.new(payment.id, card.id) }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, user_id: user.id) }

    it do
      expect(Wayforpay::Payments).to receive(:hold).once
      subject.call
    end
    it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }

    context 'when smth went wrong from wayforpay' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      it { is_expected.not_to change { payment.reload.status } }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(wayforpay_body)) }
    end
  end
end
