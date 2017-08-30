describe Events::CreateFeedback do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      Factory.structs[:feedback].to_h.merge(
        user_id: user.id,
        trip_id: trip.id
      )
    end
    let(:user) { Factory[:user] }
    let(:trip) { Factory[:trip] }

    it { is_expected.to change { users_repository.all.count }.by(+1) }

    context 'when data is invalid' do
      let(:data) { Factory.structs[:feedback].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when rate is greater than 5' do
      let(:data) { Factory.structs[:feedback].to_h.merge(rate: 10) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
