describe FeedbacksController, type: :controller do
  let(:user) { Factory[:user] }

  describe '#create' do
    subject { response }

    let(:params) { { trip_id: trip.id, feedback: feedback_params, auth_token: user.auth_token } }
    let(:feedback_params) { Factory.structs[:feedback].to_h.except(:id) }
    let(:trip) { Factory[:trip] }

    before { post :create, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when params are invalid' do
      let(:feedback_params) { Factory[:feedback].to_h.except(:id, :rate) }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
