describe Presenters::Drivers::SinglePublic do
  let(:car) { Factory[:car] }
  let(:driver) { Factory[:driver, car_id: car.id] }

  subject { described_class.new(driver).to_json }

  it { is_expected.to have_key(:id).with_value(driver.id) }
  it { is_expected.to have_key(:name).with_value(driver.name) }
  it { is_expected.to have_key(:car_id).with_value(driver.car_id) }
end
