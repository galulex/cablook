describe Operations::Wayforpay::RetryPendings do
  let(:instance) { described_class.new(user.id, card.id) }
  let(:user) { Factory[:user] }
  let(:card) { Factory[:card, user_id: user.id] }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { Factory[:payment, user_id: user.id, status: Constants::Payments::PENDING] }

    it { is_expected.to change { payment_repository.by_id(payment.id).status }.to(Constants::Payments::SUCCESS) }
    it do
      expect(Wayforpay::Payments).to receive(:hold).once
      subject.call
    end

    context 'when card not found' do
      let(:card) { Factory[:card] }

      it do
        expect(Wayforpay::Payments).not_to receive(:hold)
        subject.call
      end

      context 'when card owned by another user' do
        let(:card) { Factory[:card, user_id: another_user.id] }
        let(:another_user) { Factory[:user] }

        it do
          expect(Wayforpay::Payments).not_to receive(:hold)
          subject.call
        end
      end
    end

    context 'when smth went wrong from wayforpay' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      it { is_expected.not_to change { payment_repository.by_id(payment.id).status } }
    end
  end
end
