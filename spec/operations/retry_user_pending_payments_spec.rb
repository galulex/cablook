describe Operations::RetryUserPendingPayments do
  let(:instance) { described_class.new(user.id, card.id) }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before do
    allow_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call)
  end

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING) }

    it do
      expect_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call).once
      subject.call
    end

    context 'when card not found' do
      let(:card) { create(:card) }

      it do
        expect_any_instance_of(Operations::Wayforpay::RetryPayment).not_to receive(:call)
        subject.call
      end

      context 'when card owned by another user' do
        let(:card) { create(:card, user_id: another_user.id) }
        let(:another_user) { create(:user) }

        it do
          expect_any_instance_of(Operations::Wayforpay::RetryPayment).not_to receive(:call)
          subject.call
        end
      end
    end
  end
end
