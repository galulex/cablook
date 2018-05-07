describe Api::FeedbacksController, type: :controller do
  let(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#create' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { trip_id: trip.id, feedback: feedback_params, auth_token: user.auth_token } }
    let(:feedback_params) { Factory.structs[:feedback].to_h.except(:id) }
    let(:trip) { Factory[:trip] }
    let(:user) { Factory[:user] }

    before { post :create, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:feedback_params) { Factory[:feedback].to_h.except(:id, :rate) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
