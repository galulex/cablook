describe Jobs::PaymentHold do
  after { described_class.new.perform(trip.id, card.id) }

  let(:trip) { Factory[:trip, status: Constants::Trip::PENDING] }
  let(:card) { Factory[:card] }

  before do
    allow(Operations::Wayforpay).to receive(:hold)
    allow(Operations::Wayforpay).to receive(:refund)
  end

  it { expect(Operations::Wayforpay).to receive(:hold) }
  it { expect(Operations::Wayforpay).not_to receive(:refund) }

  context 'when trip is canceled' do
    let(:trip) { Factory[:trip, status: Constants::Trip::CANCELED] }

    it { expect(Operations::Wayforpay).to receive(:refund) }
  end
end
