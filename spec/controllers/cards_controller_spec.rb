describe CardsController, type: :controller do
  let(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before { get :index, as: :json }

    it_behaves_like 'authorization_required'

    it { is_expected.to have_http_status(:success) }
  end
end
