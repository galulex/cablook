describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { create(:user) }
    let(:params) { { phone_number: user.phone_number } }

    context 'invalid data' do
      let(:params) { { user: { phone_number: '' } } }

      before { post :create, params: params }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when device_params is send' do
      let(:params) do
        {
          phone_number: user.phone_number,
          device: device_attrs
        }
      end
      let(:device_attrs) { attributes_for(:device) }

      before { post :create, params: params }

      it { is_expected.to be_successful }
    end
  end
end
