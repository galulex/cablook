require 'spec_helper'

RSpec.describe Trip, type: :model do
  describe '#vip' do
    subject { trip.vip }

    context 'when user is vip' do
      let!(:trip) { build(:trip, user: user) }
      let(:user) { build(:user, vip: true) }

      it { is_expected.to be_truthy }
    end

    context 'when trip_payment has business card' do
      let!(:trip) { build(:trip, user: user, trip_payment: trip_payment) }
      let(:user) { build(:user) }
      let(:business) { build(:business) }
      let(:trip_payment) { build(:trip_payment, card: business.card) }
      before { user.businesses << business }

      it { is_expected.to be_truthy }
    end
  end
end
