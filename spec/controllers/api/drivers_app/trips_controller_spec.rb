describe Api::DriversApp::TripsController, type: :controller do
  let(:driver) { Factory[:driver] }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before { get :index, as: :json }

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
