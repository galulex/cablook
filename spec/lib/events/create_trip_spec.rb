describe Events::CreateTrip do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:trip, user_id: user.id].to_h }
    let(:user) { Factory[:user] }

    it { is_expected.to change { trips_repository.trips.count }.by(+1) }

    context 'when path is invalid' do
      let(:data) { Factory.structs[:trip].to_h.except(:path) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when cost is invalid' do
      let(:data) { Factory.structs[:trip].to_h.except(:cost) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is invalid' do
      let(:data) { Factory.structs[:trip].to_h.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
