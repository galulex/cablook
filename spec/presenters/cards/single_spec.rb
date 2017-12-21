describe Presenters::Cards::Single do
  let(:card) { Factory[:card] }

  subject { described_class.new(card).to_json }

  it { is_expected.to have_key(:id).with_value(card.id) }
  it { is_expected.to have_key(:token).with_value(card.token) }
  it { is_expected.to have_key(:pan).with_value(card.pan) }
  it { is_expected.to have_key(:type).with_value(card.type) }
  it { is_expected.to have_key(:currency).with_value(card.currency) }
end
