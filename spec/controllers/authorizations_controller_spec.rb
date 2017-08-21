describe AuthorizationsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) do
      { user: {
        email: user.email,
        password: '12341234'
      } }
    end

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }

    context 'when something went wrong' do
      let(:params) do
        { user: {
          email: Faker::Name.name,
          password: Faker::Internet.password
        } }
      end

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
