describe Verifications::PhoneNumbersController, type: :controller do
  describe '#send_verification' do
    subject { response }

    let(:params) { { phone_number: phone_number } }
    let(:user) { Factory[:user] }
    let(:phone_number) { user.phone_number }

    before do
      allow_any_instance_of(Events::Verifications::SendNumberVerification).to receive(:send_verification_code)
      get :send_verification, params: params, as: :json
    end

    it { is_expected.to have_http_status(:success) }

    context 'when params are invalid' do
      let(:phone_number) { "+#{Faker::Number.number(12)}" }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#verify' do
    subject { response }

    let(:params) { { phone_number: phone_number, token: token } }
    let(:user) { Factory[:user, verification_token: token] }
    let(:phone_number) { user.phone_number }
    let(:token) { '1111' }

    before { post :verify, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when phone_number is invalid' do
      let(:phone_number) { "+#{Faker::Number.number(12)}" }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when token is invalid' do
      let(:params) { { phone_number: phone_number, token: '0000' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
