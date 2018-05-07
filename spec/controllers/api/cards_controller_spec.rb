describe Api::CardsController, type: :controller do
  let(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before { get :index, as: :json }

    it_behaves_like 'authorization_required'

    it { is_expected.to be_successful }
  end

  describe '#create' do
    subject { response }

    let(:params) { JSON.parse(File.read('spec/fixtures/card_callback.json')) }

    before { post :create, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { super().merge(recToken: nil) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#delete' do
    subject { response }

    let(:params) { { id: card.id } }
    let(:card) { Factory[:card, user_id: user.id] }

    before { delete :destroy, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { { id: 999 } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
