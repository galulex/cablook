describe Operations::RetryUserPendingPayments do
  let(:instance) { described_class.new(user.id, card.id) }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
  let(:fondy_retry_response) { { response_status: Constants::Payments::FONDY_SUCCESS } }
  let(:wfp) { double(call: OpenStruct.new(body: wayforpay_body)) }

  before do
    allow_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call) { OpenStruct.new(body: wayforpay_body) }
    allow_any_instance_of(Operations::Fondy::RetryPayment).to receive(:call) { fondy_retry_response }
  end

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { create(:trip, status: Constants::Trip::FINISHED) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, status: Constants::Payments::PENDING) }

    it do
      expect_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call).once
      subject.call
    end

    context 'when ok response' do
      it do
        expect_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call).once
        subject.call
      end
    end

    context 'when payment system Fondy' do
      before do
         Settings.get.update!(payment_system: :fondy) 
         allow_any_instance_of(Operations::Payments::RetryPayment).to receive(:is_fondy_method?).and_return(true)
      end

      it do
        expect_any_instance_of(Operations::Fondy::RetryPayment).to receive(:call).once
        subject.call
      end
    end

    context 'when bad reponse' do
      let(:wayforpay_body) { { reasonCode: '1104' }.to_json }
      let!(:another_card) { create(:card, user_id: user.id) }

      before do
        allow(Operations::Wayforpay::RetryPayment).to receive(:new) { wfp }
      end

      it do
        expect(wfp).to receive(:call).twice
        subject.call
      end
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
