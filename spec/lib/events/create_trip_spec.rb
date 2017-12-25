describe Events::CreateTrip do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:trip, user_id: user.id].to_h }
    let(:user) { Factory[:user] }

    it { is_expected.to change { trips_repository.trips.count }.by(+1) }

    context 'and active job is created' do
      it { is_expected.to have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
    end

    context 'and trip_job is created' do
      it { is_expected.to change { trip_jobs_repository.trip_jobs.count }.by(+1) }
    end

    context 'and payment is created' do
      it { is_expected.to change { payments_repository.payments.count }.by(+1) }
    end

    context 'when path is empty' do
      let(:data) { Factory.structs[:trip].to_h.except(:path) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when cost is empty' do
      let(:data) { Factory.structs[:trip].to_h.except(:cost) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is empty' do
      let(:data) { Factory.structs[:trip].to_h.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
