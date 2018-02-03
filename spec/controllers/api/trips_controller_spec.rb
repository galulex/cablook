describe Api::TripsController, type: :controller do
  let(:user) { Factory[:user] }
  let!(:card) { Factory[:card, user_id: user.id] }
  let(:auth_token) { user.auth_token }
  let(:wayforpay_body) { { reasonCode: '1100' }.to_json }

  before do
    request.headers['Auth-Token'] = auth_token
    allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) }
  end

  describe '#create' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { trip: trip_params } }
    let(:trip_params) { Factory.structs[:trip].to_h.except(:id) }

    before { post :create, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when params are invalid' do
      let(:trip_params) { Factory[:trip].to_h.except(:id, :path) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#index' do
    subject { response }

    before { get :index, as: :json, params: params }
    let(:params) { {} }

    it { is_expected.to have_http_status(:success) }

    context 'with pagination' do
      let(:params) { { page: 1, per: 1 } }

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe '#show' do
    subject { response }

    let(:params) { { id: trip.id } }
    let(:trip) { Factory[:trip] }

    before { get :index, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#cancel' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { Factory[:trip] }

    before { patch :cancel, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when trip is finished' do
      let(:trip) { Factory[:trip, status: Constants::Trip::FINISHED] }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
