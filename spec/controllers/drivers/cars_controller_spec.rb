describe Drivers::CarsController, type: :controller do
  let(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    let(:params) { { auth_token: user.auth_token } }

    before { get :index, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }
  end
end
