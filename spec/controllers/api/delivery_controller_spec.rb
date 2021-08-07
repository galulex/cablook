describe Api::DeliveryController, type: :controller do
  subject { response }

  let(:user) { create :user }
  let(:auth_token) { user.auth_token }
  let(:vendor) { create :vendor }

  before do
    request.headers['Auth-Token'] = auth_token
    Price.create
  end

  describe '#new' do
    it_behaves_like 'authorization_required'
    let(:params) { { destination: '49.426269,32.054189', destination_address: 'Active Bridge', vendor_id: vendor.id } }

    before { get :new, params: params }

    it { is_expected.to be_successful }
    it { expect(subject.body).to include(params[:destination_address]) }

    context 'whith invalid params' do
      let(:params) { { vendor_id: vendor.id } }

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end

  describe '#create' do
    let!(:card) { create :card, user_id: user.id }
    let(:trip_params) { attributes_for :trip, user_id: user.id }
    let(:items) { { '4537' => { 'total_price' => '125', 'quantity' => 1 } } }
    let(:time) { Time.zone.now.strftime('%H:%M') }
    let(:params) do
      { order: { vendor_id: vendor.id,
                 trip_time: time,
                 card_id: card.id,
                 user_id: user.id,
                 trip: trip_params,
                 items: items } }
    end

    context 'success' do
      let(:payment_status) { { 'reasonCode' => Constants::Payments::WAYFORPAY_SUCCESS } }

      before do
        allow_any_instance_of(Events::Orders::Create).to receive(:hold_money) { payment_status }
        allow_any_instance_of(Events::Orders::Create).to receive(:create_order_payment) { true }
        allow_any_instance_of(Events::Trips::Create).to receive(:assign_trip_to_order_payment) { true }
        post :create, params: params, as: :json
      end

      it { is_expected.to be_successful }
    end

    context 'invalid params' do
      let(:params) { { order: { vendor_id: vendor.id, trip_time: time, trip: trip_params } } }

      before { post :create, params: params, as: :json }

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end
end
