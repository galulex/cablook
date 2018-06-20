describe Jobs::PaymentRefundDeclined do
  after { described_class.new.perform(trip.id) }

  let(:trip) { create(:trip, status: Constants::Trip::PENDING) }

  before { allow(Operations::Wayforpay).to receive(:refund) }

  it { expect(Operations::Wayforpay).not_to receive(:refund) }

  context 'when trip is declined' do
    let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }

    it { expect(Operations::Wayforpay).to receive(:refund) }
  end
end
