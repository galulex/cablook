describe Events::Trips::Cancel do
  describe '.call' do
    let(:trip) { create(:trip, status: Constants::Trip::PENDING) }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user.id) }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }

    context 'and job deleted' do
      before do
        job = Jobs::SearchCarForTrip.perform_later(trip.id)
        create(:trip_job, trip_id: trip.id, activejob_id: job.job_id, sidekiq_id: job.provider_job_id)
      end

      it { is_expected.not_to have_enqueued_job(Jobs::SearchCarForTrip).with(trip.id) }
    end

    context 'and payment status is changed' do
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end

    context 'when trip is on the way' do
      let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY) }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }
    end

    context 'when canceled by driver' do
      let(:data) { { trip_id: trip.id, by_driver: true } }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED_BY_DRIVER]) }
    end

    context 'when trip not found' do
      let(:data) { { trip_id: 100_000 } }

      it { is_expected.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when trip is declined' do
      let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }

      it { is_expected.not_to change { trip.reload.status } }
    end

    context 'when trip is finished' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is already canceled' do
      let(:trip) { create(:trip, status: Constants::Trip::CANCELED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is driving' do
      let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
