describe Api::DriversApp::AssignCarController, type: :controller do
  let(:driver) { create(:driver) }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { driver: { car_id: car.id, name: 'name' } } }
    let(:car) { create(:car) }

    before { patch :update, params: params, as: :json }

    it { is_expected.to be_successful }
  end
end
