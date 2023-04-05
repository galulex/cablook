describe Events::BonusTrips::CreateGift do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { user_id: create(:user).id } }

    it { is_expected.to raise_error(Events::InvalidParamsError) }

    context 'when user_id is missing' do
      let(:data) { super().except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
