describe Events::Users::Remove do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:user) { create(:user) }
    let(:data) { { user_id: user.id } }

    it { is_expected.to change { user.reload.deleted_at } }

    context 'when have unpaid trips' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
