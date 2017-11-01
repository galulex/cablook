describe DriversApp::CarsController, type: :controller do
  let(:driver) { Factory[:driver] }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before { get :index, as: :json }

    it { is_expected.to have_http_status(:success) }
  end
end
