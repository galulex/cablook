describe Api::DevicesController, type: :controller do
  let(:user) { create(:user) }

  describe '#create' do
    subject { response }

    context 'when token is invalid' do
      before { post :create }

      it { is_expected.to have_http_status(404) }
    end

    context 'when token is valid' do
      let(:params) { { device: attributes_for(:device) } }

      before { request.headers['Auth-Token'] = user.auth_token }

      it do
        post :create, params: params
        is_expected.to be_successful
      end

      it do
        expect do
          post :create, params: params
        end.to change { Device.count }.by(1)
      end
    end
  end
end
