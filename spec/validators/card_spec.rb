describe Validators::Card do
  subject { described_class.new(data).validate }

  let(:card_attrs) { Factory.structs[:card].to_h.except(:user) }
  let(:data) { card_attrs }

  it { is_expected.to be true }

  describe 'token must be unique' do

    let(:data) { card_attrs.merge(token: card.token) }
    let(:card) { Factory[:card] }

    it { is_expected.to be false }
  end

  describe 'token must be presence' do
    let(:data) { card_attrs.merge(token: nil) }

    it { is_expected.to be false }
  end

  describe 'pan must be presence' do
    let(:data) { card_attrs.merge(pan: nil) }

    it { is_expected.to be false }
  end

  describe 'user_id must be presence' do
    let(:data) { card_attrs.merge(user_id: nil) }

    it { is_expected.to be false }
  end
end
