describe Events::Trips::Cancel do
  describe '.call' do
    let(:trip) { Factory[:trip, status: Constants::Trip::PENDING] }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::CANCELED) }

    context 'and job deleted' do
      before do
        job = Jobs::SearchCarForTrip.perform_later(trip.id)
        Factory[:trip_job, trip_id: trip.id, activejob_id: job.job_id, sidekiq_id: job.provider_job_id]
      end

      it { is_expected.not_to have_enqueued_job(Jobs::SearchCarForTrip).with(trip.id) }
    end

    context 'and refund payment job is running' do
      it { is_expected.to have_enqueued_job(Jobs::PaymentRefund).with(trip.id) }
    end

    context 'when trip is on the way' do
      let(:trip) { Factory[:trip, status: Constants::Trip::ON_THE_WAY] }

      it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::CANCELED) }
    end

    context 'when trip is finished' do
      let(:trip) { Factory[:trip, status: Constants::Trip::FINISHED] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is already canceled' do
      let(:trip) { Factory[:trip, status: Constants::Trip::CANCELED] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is driving' do
      let(:trip) { Factory[:trip, status: Constants::Trip::DRIVING] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
