describe Operations::Fondy::DoPayment do
  let(:instance) { described_class.new(trip.id, payment_type, amount) }
  let(:fondy_capture_response) { { response: 
                                  { 
                                    order_id: 'test309906285',
                                    response_status: 'success',
                                    response_code: '',
                                    capture_status: 'captured', 
                                    response_description: '', 
                                    merchant_id:'1' 
                                  } 
                                }.to_json }

  before { allow_any_instance_of(::Fondy::Capture).to receive(:call) { fondy_capture_response } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, order_reference: 'test', status: Constants::Payments::PENDING) }
    let!(:payment_type) { 'Trip' }
    let(:amount) { payment.amount }
    let(:trip) { create(:trip, user_id: user.id, driver_id: driver.id, status: Constants::Trip::FINISHED) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }
    let(:driver) { create(:driver) }

    context 'when payment have success status' do

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
    end

    context 'when payment_type is Trip' do

      it { is_expected.to change { trip.reload.total }.from(0).to(trip.payments.sum(:amount)) }

      context 'and fondy status is ok' do

        it { is_expected.to change { Payments::PayOut.count }.by(+1) }
        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
        it { is_expected.to change { payment.reload.response }.from(nil) }
      end

      context 'and fondy status is not ok' do
        let(:fondy_capture_response) { { response: { response_status: 'failure' } }.to_json }

        it { is_expected.not_to change { Payments::PayOut.count } }
        it { is_expected.not_to change { payment.reload.status } }
        it { is_expected.to change { payment.reload.response } }
      end
    end

    context 'when payment_type is Tip' do
      let!(:payment_type) { 'Tip' }
      let(:amount) { 5 }
      let(:trip) { create(:trip, user_id: user.id, driver_id: driver.id) }
      let(:payment) { create(:tip_payment, user_id: user.id, trip_id: trip.id, card_id: card.id, order_reference:'tip', amount: amount) }
      let(:instance) { described_class.new(trip.id, payment_type, amount) }

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
      it { is_expected.to change { trip.reload.total }.from(0).to(amount) }

      context 'and wayforpay status is ok' do
        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and wayforpay status is not ok' do
        let(:fondy_capture_response) { { response: { response_status: 'failure' } }.to_json }

        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::PENDING) }
      end
    end

    context 'when payment_type is FakeTaxi' do
      let!(:payment_type) { 'FakeTaxi' }
      let(:amount) { Constants::Payments::FAKE_TAXI_COST }
      let(:trip) { create(:trip, user_id: user.id, cost: amount, driver_id: driver.id) }
      let(:payment) { create(:fake_taxi_payment, trip_id: trip.id, user_id: user.id, card_id: card.id, order_reference: 'test', amount: amount) }
      let(:instance) { described_class.new(trip.id, payment_type, amount) }

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
      it { is_expected.to change { trip.reload.total }.from(0).to(amount) }

      context 'and wayforpay status is ok' do
        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and wayforpay status is not ok' do
        let(:fondy_capture_response) { { response: { response_status: 'failure' } }.to_json }

        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::PENDING) }
      end
    end
  end
end
