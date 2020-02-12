describe Operations::Wayforpay::DoPayment do
  let(:instance) { described_class.new(trip.id, payment_type, amount) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id) }
    let!(:payment_type) { 'Trip' }
    let(:amount) { payment.amount }
    let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when payment_type is Trip' do
      context 'and payment status is Bonus' do
        let(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, status: Constants::Payments::BONUS) }

        it { is_expected.not_to change { payment.reload.status } }
        it { is_expected.not_to change { payment.reload.response } }
        it { is_expected.not_to change { trip.reload.total } }
      end

      it { is_expected.to change { trip.reload.total }.from(0).to(trip.payments.sum(:amount)) }

      context 'and wayforpay status is ok' do
        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
        it { is_expected.to change { payment.reload.response }.from(nil) }

        it do
          expect(Wayforpay::Payments).to receive(:hold).once
          subject.call
        end
      end

      context 'and wayforpay status is not ok' do
        let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

        it { is_expected.not_to change { payment.reload.status } }
        it { is_expected.to change { payment.reload.response } }
      end

      context 'and user have frozen bonuses' do
        let(:frozen_bonus) { create(:bonus_trip, user_id: user.id, status: :iced) }

        it { is_expected.to change { frozen_bonus.reload.fresh? }.to be_truthy }

        context 'and user have not finished trips' do
          let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::PENDING) }

          it { is_expected.not_to change { frozen_bonus.reload.status } }
        end

        context 'and wayforpay status is not ok' do
          let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

          it { is_expected.not_to change { frozen_bonus.reload.status } }
        end
      end
    end

    context 'when payment_type is Tip' do
      let!(:payment_type) { 'Tip' }
      let(:amount) { 5 }
      let(:trip) { create(:trip, user_id: user.id, cost: total) }
      let(:payment) { create(:payment, user_id: user.id, trip_id: trip.id, card_id: card.id, amount: total) }
      let(:total) { 25 }
      let(:instance) { described_class.new(trip.id, payment_type, amount) }

      it { is_expected.to change { Payments::Tip.count }.by(+1) }
      it { is_expected.to change { trip.reload.total }.from(0).to(total + amount) }

      context 'and wayforpay status is ok' do
        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and wayforpay status is not ok' do
        let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::PENDING) }
      end
    end

    context 'when payment_type is Idle' do
      let!(:payment_type) { 'Idle' }
      let!(:amount) { 15 }
      let(:trip) { create(:trip, user_id: user.id, cost: total) }
      let(:payment) { create(:payment, user_id: user.id, trip_id: trip.id, card_id: card.id, amount: total) }
      let(:total) { 40 }
      let(:instance) { described_class.new(trip.id, payment_type, amount) }

      it { is_expected.to change { Payments::Idle.count }.by(+1) }
      it { is_expected.to change { trip.reload.total }.from(0).to(total + amount) }

      context 'and wayforpay status is ok' do
        let(:idle_payment) { Payments::Idle.last }

        before { subject.call }

        it { expect(Payments::Idle.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and wayforpay status is not ok' do
        let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

        before { subject.call }

        it { expect(Payments::Idle.last.status).to eq(Constants::Payments::PENDING) }
      end
    end

    context 'when payment_type is FakeTaxi' do
      let!(:payment_type) { 'FakeTaxi' }
      let!(:price) { Price.create }
      let(:amount) { price.landing / 100 }
      let(:trip) { create(:trip, user_id: user.id, cost: total) }
      let(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, amount: total) }
      let(:total) { 40 }
      let(:instance) { described_class.new(trip.id, payment_type, amount) }

      it { is_expected.to change { Payments::FakeTaxi.count }.by(+1) }
      it { is_expected.to change { trip.reload.total }.from(0).to(total + amount) }

      context 'and wayforpay status is ok' do
        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and wayforpay status is not ok' do
        let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::PENDING) }
      end
    end
  end
end
