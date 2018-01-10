describe Admin::CarsController, type: :controller do
  subject { response }

  describe '#index' do
    before { get :index }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#new' do
    before { get :new }

    it { is_expected.to have_http_status(:success) }
  end

  describe '#create' do
    let(:params) { Factory.structs[:car].to_h.slice(:number) }

    before { post :create, params: { car: params } }

    it { is_expected.to have_http_status(:found) }
  end

  describe '#update' do
    let!(:car) { Factory[:car] }
    let(:params) { { id: car.id, car: { number: '1111' } } }

    before { patch :update, params: params }

    it { is_expected.to have_http_status(:found) }
  end

  describe '#destroy' do
    let!(:car) { Factory[:car] }
    let(:params) { { id: car.id } }

    before { delete :destroy, params: params }

    it { is_expected.to have_http_status(:found) }
  end
end
