describe DriversApp::AuthenticationsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:driver) { Factory[:driver] }
    let(:params) { { driver: { username: driver.username, password: '12341234' } } }

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }

    context 'when username is blank' do
      let(:params) { { driver: { username: '', password: Faker::Internet.password } } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
