describe Events::CreateTrip do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip_params) { Factory.structs[:trip, user_id: user.id].to_h }
    let(:data) { trip_params }
    let(:user) { Factory[:user] }

    it { is_expected.to change { trip_repository.trips.count }.by(+1) }

    context 'and active job is created' do
      it { is_expected.to have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
    end

    context 'and trip_job is created' do
      it { is_expected.to change { trip_job_repository.trip_jobs.count }.by(+1) }
    end

    context 'and payment is created' do
      it { is_expected.to change { payment_repository.payments.count }.by(+1) }
    end

    context 'when path is empty' do
      let(:data) { trip_params.except(:path) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when cost is empty' do
      let(:data) { trip_params.except(:cost) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when cost is int' do
      let(:data) { trip_params.except(:cost) }

      before { data[:cost] = data[:cost].to_i }

      it { is_expected.to change { trip_repository.trips.count }.by(+1) }
    end

    context 'when user_id is empty' do
      let(:data) { trip_params.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
