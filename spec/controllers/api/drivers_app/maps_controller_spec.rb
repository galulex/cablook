describe Api::DriversApp::MapsController, type: :controller do
  let(:driver) { create(:driver) }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before do
      car = create(:car)
      create(:driver, car_id: car.id)
      get :index, as: :json
    end

    it { is_expected.to be_successful }
  end
end
