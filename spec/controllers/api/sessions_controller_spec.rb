describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) { { phone_number: user.phone_number } }

    context 'valid data' do
      before do
        post :create, params: params
      end

      it { is_expected.to have_http_status(:success) }
    end

    context 'invalid data' do
      let(:params) { { user: { phone_number: '' } } }

      before { post :create, params: params }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#update' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) { { phone_number: user.phone_number, token: token } }
    let(:token) { user.verification_token }

    before { patch :update, params: params }

    context 'valid data' do
      pending { is_expected.to have_http_status(:success) }
    end

    context 'invalid data' do
      let(:token) { '0000' }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
