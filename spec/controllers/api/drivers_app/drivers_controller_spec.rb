describe Api::DriversApp::DriversController, type: :controller do
  let(:driver) { create(:driver) }
  let(:auth_token) { driver.auth_token }
  let(:device_token) { 'device_token' }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    subject { response }

    before { post :update, params: { device: device_token } }

    it { is_expected.to be_successful }
  end
end
