describe DriversApp::AssignCarController, type: :controller do
  let(:driver) { Factory[:driver] }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { driver: { car_id: car.id, name: 'name' } } }
    let(:car) { Factory[:car] }

    before { patch :update, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }
  end
end
