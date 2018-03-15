describe Events::BonusTrips::CreateGift do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { user_id: Factory[:user].id } }

    it { is_expected.to change { bonus_trip_repository.bonus_trips.count }.by(+1) }

    context 'when user_id is missing' do
      let(:data) { super().except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
