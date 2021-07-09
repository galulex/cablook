describe Events::Orders::Create do
  describe '.call' do
    before {
      allow_any_instance_of(described_class).to receive(:hold_money) { { 'reasonCode' => Constants::Payments::WAYFORPAY_SUCCESS } }
      allow_any_instance_of(described_class).to receive(:items) { { 'Category' => {'icon' => 'meat', 'items' => [{ 'id' => '4537', 'name' => 'Item', 'price' => '125' }]} } }
      allow_any_instance_of(described_class).to receive(:create_order_payment) { true }
    }

    subject { -> { described_class.call(data) } }

    let!(:vendor) { create(:vendor) }
    let(:time) { '14:00' }
    let(:order_params) {
      {
        user_id: user.id,
        card_id: card.id,
        trip_time: time,
        vendor_id: vendor.id,
        items: ActionController::Parameters.new({ '4537' => ActionController::Parameters.new({ 'quantity' => 1 }) }).permit!
      }
    }

    let(:data) { order_params }
    let!(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }

    it { is_expected.to change { Order.count }.by(+1) }

    context 'when user_id is empty' do
      let(:data) { order_params.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user manually edit items' do
      let(:data) {
        {
          user_id: user.id,
          card_id: card.id,
          trip_time: (Time.now + 2.hours).strftime('%H:%M'),
          vendor_id: vendor.id,
          items: ActionController::Parameters.new({'Item, Category'=>ActionController::Parameters.new({ 'quantity'=>1 }) }).permit!
        }
      }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user have pending payments' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user already has pending trip' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::PENDING) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when order time is not in working hours range' do
      let(:time) { '02:00' }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when vendor open 24/7' do
      before do
        vendor.update(open_at: '02:00', close_at: '01:59')
      end

      context 'in the night' do
        let(:time) { '02:00' }

        it { is_expected.to change { Order.count }.by(+1) }
      end

      context 'in the morning' do
        let(:time) { '09:00' }

        it { is_expected.to change { Order.count }.by(+1) }
      end

      context 'in the dinner' do
        let(:time) { '13:00' }

        it { is_expected.to change { Order.count }.by(+1) }
      end

      context 'in the evening' do
        let(:time) { '17:00' }

        it { is_expected.to change { Order.count }.by(+1) }
      end
    end
  end
end
