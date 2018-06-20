describe Api::DriversApp::TripsController, type: :controller do
  let(:driver) { create(:driver, car_id: car.id) }
  let(:car) { create(:car) }
  let(:user) { create(:user) }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before { get :index, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#currents' do
    subject { response }

    before do
      the_user = create(:user)
      trip = create(:trip, status: Constants::Trip::ON_THE_WAY, user_id: the_user.id, driver_id: driver.id)
      create(:payment, trip_id: trip.id, user_id: the_user.id)
      get :currents, as: :json
    end

    it { is_expected.to be_successful }
  end

  describe '#cancel' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { patch :cancel, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when trip is finished' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#accept' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before do
      Redis.current.set("car_#{driver.car_id}", '49.461655,32.165358')
      patch :accept, params: params, as: :json
    end

    it { is_expected.to be_successful }

    context 'when driver without car' do
      let(:driver) { create(:driver) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#start' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { patch :start, params: params, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#finish' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { patch :start, params: params, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#waiting_client' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { patch :waiting_client, params: params, as: :json }

    it { is_expected.to be_successful }
  end
end
