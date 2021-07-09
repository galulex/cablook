describe Events::Delivery::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    before do
      allow_any_instance_of(Events::Orders::Create).to receive(:hold_money) { payment_status }
      allow_any_instance_of(Events::Orders::Create).to receive(:items) { vendor_items }
      allow_any_instance_of(Events::Orders::Create).to receive(:create_order_payment) { true }
      allow_any_instance_of(Events::Trips::Create).to receive(:assign_trip_to_order_payment) { true }
    end

    let(:payment_status) { { 'reasonCode' => Constants::Payments::WAYFORPAY_SUCCESS } }
    let(:vendor_items) { { 'Category' => {'icon' => 'meat', 'items' => [{ 'id' => '4537', 'name' => 'Item', 'price' => '125' }]} } }
    let!(:price) { Price.create }
    let!(:card) { create :card, user_id: user.id }
    let(:vendor) { create :vendor }
    let(:user) { create :user }
    let(:trip_params) { attributes_for :trip, user_id: user.id }
    let(:items) { { '4537' => { 'quantity' => 1 } } }
    let(:time) { Time.now.strftime('%H:%M') }
    let(:data) do
      { vendor_id: vendor.id,
        trip_time: time,
        card_id: card.id,
        user_id: user.id,
        trip: trip_params,
        items: items }
    end

    it { is_expected.to change(Order, :count).by(+1) }
    it { is_expected.to change(Trip, :count).by(+1) }
    it { is_expected.to change(Order.where(items: items), :count).by(+1) }
    it { is_expected.not_to raise_error(Events::InvalidParamsError) }

    context 'with invalid params' do
      let(:data) { { vendor_id: vendor.id, trip_time: time, card_id: card.id, user_id: user.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    # TODO: check time validation
    context 'when order is invalid' do
      let(:items) { { '4444' => { 'quantity' => 2 } } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when invalid trip params' do
      let(:trip_params) { { destination: 'test_des', destination_address: 'test_addr' } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
