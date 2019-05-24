describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { create(:user) }
    let(:params) { { phone_number: user.phone_number } }

    context 'valid data' do
      it do
        post :create, params: params
        is_expected.to be_successful
      end

      it { expect { post :create, params: params }.to have_enqueued_job(Jobs::Sms) }
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
          device: device_attrs
        }
      end
      let(:device_attrs) { attributes_for(:device) }

      before { post :create, params: params }

      it { is_expected.to be_successful }
    end

    context 'when firebase parameter is true' do
      let(:params) { { phone_number: user.phone_number, firebase: true } }

      it { expect { post :create, params: params }.to_not have_enqueued_job(Jobs::Sms) }
    end
  end

  describe '#update' do
    subject { response }

    let!(:user) { create(:user) }
    let(:params) { { phone_number: user.phone_number, token: token } }
    let(:token) { user.verification_token }

    before { patch :update, params: params }

    it { is_expected.to be_successful }

    context 'invalid data' do
      let(:token) { '0000' }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
