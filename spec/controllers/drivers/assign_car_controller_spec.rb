describe Drivers::AssignCarController, type: :controller do
  let(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { driver: { car_id: car.id, name: 'name', auth_token: user.auth_token } } }
    let(:driver_params) { Factory.structs[:driver].to_h.except(:id) }
    let(:car) { Factory[:car] }

    before { patch :update, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }
  end
end
