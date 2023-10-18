describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { create(:user) }
    let(:device_attrs) { attributes_for(:device) }

    context 'invalid data' do
      let(:params) { { user: { phone_number: '', email: '' } } }

      before { post :create, params: params }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when user login with phone number' do
      let(:params) do
        {
          phone_number: user.phone_number,
          device: device_attrs
        }
      end

      before { post :create, params: params }

      it { is_expected.to be_successful }
    end

    context 'when user login with email' do
      let(:params) do
        {
          email: user.email,
          device: device_attrs
        }
      end

      before { post :create, params: params }

      it { is_expected.to be_successful }
    end
  end
end
