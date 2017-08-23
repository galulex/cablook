describe TripsController, type: :controller do
  let(:user) { Factory[:user] }

  describe '#create' do
    subject { response }

    let(:params) { { trip: trip_params, auth_token: user.auth_token } }
    let(:trip_params) { Factory.structs[:trip].to_h.except(:id) }

    before { post :create, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when params is invalid' do
      let(:trip_params) { Factory[:trip].to_h.except(:id, :path) }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
