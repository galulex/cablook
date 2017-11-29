describe Presenters::Trips::Single do
  let(:user) { Factory[:user] }
  let(:driver) { Factory[:driver] }
  let(:trip) { Factory[:trip, user_id: user.id, driver_id: driver.id] }

  subject { described_class.new(trip).to_json }

  it { is_expected.to have_key(:id).with_value(trip.id) }
  it { is_expected.to have_key(:status).with_value(trip.status) }
  it { is_expected.to have_key(:path).with_value(trip.path) }
  it { is_expected.to have_key(:cost).with_value(trip.cost) }
  it { is_expected.to have_key(:departure).with_value(trip.departure) }
  it { is_expected.to have_key(:destination).with_value(trip.destination) }
  it { is_expected.to have_key(:departure_address).with_value(trip.departure_address) }
  it { is_expected.to have_key(:destination_address).with_value(trip.destination_address) }
  it { is_expected.to have_key(:user_id).with_value(trip.user_id) }
  it { is_expected.to have_key(:driver_id).with_value(trip.driver_id) }
  it { is_expected.to have_key(:created_at).with_value(trip.created_at) }
end
