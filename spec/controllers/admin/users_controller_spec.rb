describe Admin::UsersController, type: :controller do
  subject { response }

  describe '#index' do
    before { get :index }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#create' do
    let(:params) { Factory.sctructs[:user].to_h.slice(:email, :phone_number) }

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#update' do
    let!(:user) { Factory[:user] }
    let(:params) { { id: user.id } }

    before { patch :update, params: params }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#destroy' do
    let!(:user) { Factory[:user] }
    let(:params) { { id: user.id } }

    before { delete :destroy, params: params }

    it { is_expected.to have_http_status(:success) }
  end
end
