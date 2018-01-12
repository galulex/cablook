describe Admin::TripsController, type: :controller do
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
    let(:user) { Factory[:user] }
    let(:params) { Factory.structs[:trip].to_h }

    before { post :create, params: { trip: params.merge(user_id: user.id) } }

    it { is_expected.to have_http_status(:found) }
  end

  describe '#destroy' do
    let!(:trip) { Factory[:trip] }
    let(:params) { { id: trip.id } }

    before { delete :destroy, params: params }

    it { is_expected.to have_http_status(:found) }
  end
end
