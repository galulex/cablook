describe Presenters::DriversApp::SinglePrivate do
  let(:driver) { create(:driver) }

  subject { described_class.new(driver).to_json }

  it { is_expected.to have_key(:id).with_value(driver.id) }
  it { is_expected.to have_key(:name).with_value(driver.name) }
  it { is_expected.to have_key(:username).with_value(driver.username) }
  it { is_expected.to have_key(:auth_token).with_value(driver.auth_token) }
end
