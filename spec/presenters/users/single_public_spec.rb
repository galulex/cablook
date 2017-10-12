describe Presenters::Users::SinglePublic do
  let(:user) { Factory[:user] }

  subject { described_class.new(user).to_json }

  it { is_expected.to have_key(:id).with_value(user.id) }
  it { is_expected.to have_key(:email).with_value(user.email) }
  it { is_expected.to have_key(:phone_number).with_value(user.phone_number) }
end
