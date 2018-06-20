describe Presenters::Trips::Detailed do
  let(:user) { create(:user) }
  let(:driver) { create(:driver, car_id: car.id) }
  let(:car) { create(:car) }
  let!(:trip) { create(:trip, user_id: user.id, driver_id: driver.id, car_id: car.id) }

  subject { described_class.new(trip).to_json }

  it { is_expected.to have_key(:id).with_value(trip.id) }
  it { is_expected.to have_key(:status).with_value(trip.status) }
  it { is_expected.to have_key(:path).with_value(trip.path) }
  it { is_expected.to have_key(:cost).with_value(trip.cost) }
  it { is_expected.to have_key(:departure).with_value(trip.departure) }
  it { is_expected.to have_key(:destination).with_value(trip.destination) }
  it { is_expected.to have_key(:departure_address).with_value(trip.departure_address) }
  it { is_expected.to have_key(:destination_address).with_value(trip.destination_address) }
  it { is_expected.to have_key(:comment).with_value(trip.comment) }
  it { is_expected.to have_key(:user_id).with_value(trip.user_id) }
  it { is_expected.to have_key(:driver_id).with_value(trip.driver_id) }
  it { is_expected.to have_key(:created_at).with_value(trip.created_at) }

  context 'detailed fields' do
    it { is_expected.to have_key(:driver_name).with_value(driver.name) }
    it { is_expected.to have_key(:car_number).with_value(car.number) }
    it { is_expected.to have_key(:car_color).with_value(car.color) }
    it { is_expected.to have_key(:car_phone_number).with_value(car.phone_number) }
    it { is_expected.to have_key(:user_number).with_value(user.phone_number) }
    it { is_expected.to have_key(:trips_count).with_value(user.reload.trips_count) }
    it { is_expected.not_to have_key(:payment_status) }

    context 'and payment created' do
      let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }

      it { is_expected.to have_key(:payment_status).with_value(payment.status) }
    end
  end
end
