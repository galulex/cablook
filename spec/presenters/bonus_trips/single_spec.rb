describe Presenters::BonusTrips::Single do
  let!(:bonus) { create(:bonus_trip, user_id: user.id, friend_id: user.id, trip_id: trip.id) }
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:trip) { create(:trip) }

  subject { described_class.new(bonus).to_json }

  it { is_expected.to have_key(:id).with_value(bonus.id) }
  it { is_expected.to have_key(:user_id).with_value(bonus.user_id) }
  it { is_expected.to have_key(:friend_id).with_value(bonus.friend_id) }
  it { is_expected.to have_key(:trip_id).with_value(bonus.trip_id) }
  it { is_expected.to have_key(:status).with_value(bonus.status) }
  it { is_expected.to have_key(:code).with_value(bonus.code) }
  it { is_expected.to have_key(:type).with_value(bonus.type) }
  it { is_expected.to have_key(:friend) }
  it { is_expected.to have_key(:user) }
end
