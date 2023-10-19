describe Api::SessionsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { create(:user, verification_code: '123456') }
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

    context 'when user login with email after phone attemt' do
      let(:valid_params) { { email: user.email, phone_number: user.phone_number } }

      before { post :create, params: valid_params }

      it { is_expected.to be_successful }
    end

    context 'when new user login with email after phone attemt' do
      let(:new_user_email) { 'new@user.mail' }
      let(:new_user_phone) { '+380731111111' }
      let(:valid_params) { { email: new_user_email, phone_number: new_user_phone } }

      before { post :create, params: valid_params }

      it { expect(response).to have_http_status(201) }
      it { expect(User.find_by(email: new_user_email, phone_number: new_user_phone)).to be_present }
      it 'returns valid response' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['email']).to eq(new_user_email)
        expect(parsed_response['phone_number']).to eq(new_user_phone)
      end
    end

    context 'when verification code is valid' do
      let(:valid_params) { { email: user.email, code: '123456' } }

      before { post :verify_code, params: valid_params }

      it { expect(response).to have_http_status(201) }
      it 'returns valid response' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['email']).to eq(user.email)
        expect(user.reload.verification_code).to be_nil
      end
    end

    context 'when verification code is invalid' do
      let(:invalid_params) { { email: user.email, code: '654321' } }

      before { post :verify_code, params: invalid_params }

      it { expect(response).to have_http_status(401) }
      it 'returns unauthorized response with error' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('User not found or invalid code')
        expect(user.reload.verification_code).to_not be_nil
      end
    end
  end
end
