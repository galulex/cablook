describe Api::Verifications::EmailsController, type: :controller do
  describe '#send_verification' do
    subject { response }

    let(:params) { { email: email } }
    let(:user) { Factory[:user, confirmation_token: 'token'] }
    let(:email) { user.email }

    before do
      allow_any_instance_of(Events::Verifications::SendEmailVerification).to receive(:send_confirmation_link)
      get :send_verification, params: params, as: :json
    end

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:email) { "+#{Faker::Internet.email}" }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#verify' do
    subject { response }

    let(:params) { { email: email, token: token } }
    let(:user) { Factory[:user, confirmation_token: token] }
    let(:email) { user.email }
    let(:token) { '1111' }

    before { post :verify, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when email is invalid' do
      let(:email) { "+#{Faker::Internet.email}" }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when token is invalid' do
      let(:params) { { email: email, token: '0000' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
