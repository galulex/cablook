describe Events::Orders::Create do
  describe '.call' do
    before {
      allow_any_instance_of(described_class).to receive(:hold_money) { { 'reasonCode': 1101 } }
      allow_any_instance_of(described_class).to receive(:items) { {'Category'=>[{'name'=>'Item', 'price'=>'125'}]} }
    }

    subject { -> { described_class.call(data) } }

    let(:order_params) {
      {
        user_id: user.id,
        card_id: card.id,
        trip_time: (Time.now + 2.hours).strftime('%H:%M'),
        vendor_id: vendor.id,
        items: ActionController::Parameters.new({'Category, Item'=>ActionController::Parameters.new({'quantity'=>1})}).permit!
      }
    }

    let(:data) { order_params }
    let!(:user) { create(:user) }
    let!(:vendor) { create(:vendor) }
    let!(:card) { create(:card, user_id: user.id) }

    it { is_expected.to change { Order.count }.by(+1) }

    context 'when user_id is empty' do
      let(:data) { order_params.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
