describe Api::DriversApp::DriversController, type: :controller do
  let(:driver) { create(:driver) }
  let(:auth_token) { driver.auth_token }
  let(:params) { { device: { device: 'device_token', device_platform: 'device_platform' } } }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    subject { response }

    before { post :update, params: params}

    it { is_expected.to be_successful }
  end
end
