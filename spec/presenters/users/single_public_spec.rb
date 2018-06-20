describe Presenters::Users::SinglePublic do
  let(:user) { create(:user) }

  subject { described_class.new(user).to_json }

  it { is_expected.to have_key(:id).with_value(user.id) }
  it { is_expected.to have_key(:email).with_value(user.email) }
  it { is_expected.to have_key(:phone_number).with_value(user.phone_number) }
  it { is_expected.to have_key(:referral_code).with_value(user.referral_code) }
  it { is_expected.to have_key(:trips_count).with_value(user.trips_count) }
end
