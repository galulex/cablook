describe Admin::DriversController, type: :controller do
  subject { response }

  describe '#index' do
    before { get :index }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#create' do
    let(:params) { Factory.structs[:driver].to_h.slice(:name, :username) }

    before { post :create, params: { driver: params } }

    it { is_expected.to have_http_status(:found) }
  end

  describe '#update' do
    let!(:driver) { Factory[:driver] }
    let(:params) { { id: driver.id, driver: { name: 'test' } } }

    before { patch :update, params: params }

    it { is_expected.to have_http_status(:found) }
  end

  describe '#destroy' do
    let!(:driver) { Factory[:driver] }
    let(:params) { { id: driver.id } }

    before { delete :destroy, params: params }

    it { is_expected.to have_http_status(:found) }
  end
end
