describe Api::DriversApp::RegistrationsController, type: :controller do
  describe '#create' do
    subject { response }

    let(:params) do
      { driver: {
        name: Faker::Lorem.word,
        username: Faker::Name.name,
        password: Faker::Internet.password,
        card_number: '4444555566661111'
      } }
    end

    before { post :create, params: params }

    it { is_expected.to be_successful }

    context 'when username is blank' do
      let(:params) do
        { driver: {
          name: Faker::Name.name,
          username: '',
          password: Faker::Internet.password
        } }
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
