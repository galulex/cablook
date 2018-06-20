describe Api::FeedbacksController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#create' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { trip_id: trip.id, feedback: feedback_params, auth_token: user.auth_token } }
    let(:feedback_params) { attributes_for(:feedback) }
    let(:user) { create(:user) }
    let(:trip) { create(:trip, user: user) }

    before { post :create, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:feedback_params) { attributes_for(:feedback).except(:rate) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
