describe Events::Trips::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip_params) { attributes_for(:trip, user_id: user.id) }
    let(:data) { trip_params }
    let(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }

    it { is_expected.to change { Trip.count }.by(+1) }

    context 'and active job is created' do
      it { is_expected.to have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
      it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(data[:id]) }
    end

    context 'and trip_job is created' do
      it { is_expected.to change { TripJob.count }.by(+1) }
    end

    context 'and user trips_count updated' do
      it { is_expected.to change { user.reload.trips_count }.from(0).to(1) }
    end

    context 'when path is empty' do
      let(:data) { trip_params.except(:path) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is empty' do
      let(:data) { trip_params.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user pre-order trip' do
      before { subject.call }

      let(:data) { trip_params.merge(time: 15.minutes.since.strftime('%H:%M')) }

      it { expect(Trip.last.start_at.strftime('%H:%M')).to eq(15.minutes.since.in_time_zone.strftime('%H:%M')) }

      context 'and start_at less then current time' do
        let(:data) { trip_params.merge(time: 3.hours.ago.strftime('%H:%M')) }

        it { expect(Trip.last.start_at.strftime('%d, %H:%M')).to eq((3.hours.ago + 1.day).in_time_zone.strftime('%d, %H:%M')) }
      end
    end

    context 'when user choose no call' do 
      before { subject.call }

      let(:data) { trip_params.merge(no_call: true) }

      it { expect(Trip.last.no_call).to eq(true) }
    end
    

    context 'when user choose entrance' do 
      before { subject.call }

      let(:data) { trip_params.merge(entrance: 1).except(:comment) }

      it { expect(Trip.last.comment).to eq('Номер подъезда: 1. ') }

      context 'and add comment' do
        let(:data) { trip_params.merge(entrance: 1, comment: 'FooBar') }

        it { expect(Trip.last.comment).to eq('Номер подъезда: 1. FooBar') }
      end
    end

    context 'when payment by bonus' do
      let!(:bonus_trip) { create(:bonus_trip, user_id: user.id, status: Constants::BonusTrip::NEW) }
      let(:data) { trip_params.merge(bonus: true) }

      before { allow_any_instance_of(Directions).to receive(:distance) { 5_000 } }

      it { is_expected.to change { Payment.count }.by(+1) }
      it { is_expected.to change { bonus_trip.reload.status }.to(Constants::BonusTrip::USED) }

      context 'but bonus was used before' do
        before { bonus_trip.update(status: Constants::BonusTrip::USED) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end

      context 'when bonus more than 10 km' do
        before { allow_any_instance_of(Directions).to receive(:distance) { 15_000 } }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end
    end

    context 'when user have pending payments' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
