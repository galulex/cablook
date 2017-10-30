describe Drivers::RegistrationsController, type: :controller do
  describe '#create' do
    subject { response }

    let(:params) do
      { driver: {
        name: Faker::Lorem.word,
        username: Faker::Name.name,
        password: Faker::Internet.password
      } }
    end

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }

    context 'when username is blank' do
      let(:params) do
        { driver: {
          name: Faker::Name.name,
          username: '',
          password: Faker::Internet.password
        } }
      end

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
