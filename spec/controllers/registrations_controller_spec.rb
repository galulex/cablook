describe RegistrationsController, type: :controller do
  describe '#create' do
    subject { response }

    let(:params) do
      { user: {
        phone_number: "+#{Faker::Number.number(12)}",
        password: Faker::Internet.password
      } }
    end

    before do
      allow_any_instance_of(Events::Verifications::SendNumberVerification).to receive(:send_verification_code)
      post :create, params: params
    end

    it { is_expected.to have_http_status(:success) }

    context 'when phone_number is blank' do
      let(:params) do
        { user: {
          phone_number: '',
          password: Faker::Internet.password
        } }
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
