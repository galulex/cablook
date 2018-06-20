describe Presenters::Users::SinglePrivate do
  let(:user) { create(:user) }

  subject { described_class.new(user).to_json }

  it { is_expected.to have_key(:id).with_value(user.id) }
  it { is_expected.to have_key(:email).with_value(user.email) }
  it { is_expected.to have_key(:phone_number).with_value(user.phone_number) }
  it { is_expected.to have_key(:auth_token).with_value(user.auth_token) }
end
