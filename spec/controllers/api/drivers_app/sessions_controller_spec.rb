describe Api::DriversApp::SessionsController , type: :controller do
  let!(:driver) { Factory[:driver] }

  subject { response }

  describe '#create' do

    let(:params) { { driver: { username: driver.username, password: '12341234' } } }

    before { post :create, params: params }

    it { is_expected.to be_successful }

    context 'when username is blank' do
      let(:params) { { driver: { username: '', password: Faker::Internet.password } } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#destroy' do
    before do
      request.headers['Auth-Token'] = driver.auth_token
      delete :destroy
    end

    it { is_expected.to be_successful }
  end
end
