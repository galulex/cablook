describe Api::NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { user.auth_token }
  let(:trip) { create(:trip, user_id: user.id) }

  before do
    request.headers['Auth-Token'] = auth_token
  end

  describe '#new' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:message) { 'Test message' }
    let(:params) { { trip_id: trip.id, message: message, message_type: 'reply' } }

    before { post :new, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when coming message' do
      let(:params) { { trip_id: trip.id, message_type: 'coming' } }

      before { post :new, params: params, as: :json }

      it { is_expected.to be_successful }
    end

    context 'when params are invalid' do
      let(:params) { { trip_id: trip.id } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
