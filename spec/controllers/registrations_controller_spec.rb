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
      allow(Events::Verifications::SendNumberVerification).to receive(:call) { 1111 }
      post :create, params: params
    end

    it { is_expected.to have_http_status(:success) }

    context 'when something went wrong' do
      let(:params) do
        { user: {
          phone_number: Faker::Name.name,
          password: Faker::Internet.password
        } }
      end

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
