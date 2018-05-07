describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) { { phone_number: user.phone_number } }

    context 'valid data' do
      before { post :create, params: params }

      it { is_expected.to be_successful }
    end

    context 'invalid data' do
      let(:params) { { user: { phone_number: '' } } }

      before { post :create, params: params }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when device_params is send' do
      let(:params) do
        {
          phone_number: user.phone_number,
          device: { token: device.token, platform: device.platform }
        }
      end
      let(:device) { Factory.structs[:device] }

      before { post :create, params: params }

      it { is_expected.to be_successful }
    end
  end

  describe '#update' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) { { phone_number: user.phone_number, token: token } }
    let(:token) { user.verification_token }

    before { patch :update, params: params }

    context 'valid data' do
      pending { is_expected.to be_successful }
    end

    context 'invalid data' do
      let(:token) { '0000' }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
