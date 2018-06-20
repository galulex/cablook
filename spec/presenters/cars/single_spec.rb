describe Presenters::Cars::Single do
  let(:car) { create(:car) }

  subject { described_class.new(car).to_json }

  it { is_expected.to have_key(:id).with_value(car.id) }
  it { is_expected.to have_key(:number).with_value(car.number) }
  it { is_expected.to have_key(:status).with_value(car.status) }
  it { is_expected.to have_key(:phone_number).with_value(car.phone_number) }
end
