describe Events::Trips::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip_params) { attributes_for(:trip, user_id: user.id) }
    let(:data) { trip_params }
    let(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }
    let!(:order) { create(:order, user_id: user.id) }
    let!(:price) { Price.create }

    it { is_expected.to change { Trip.count }.by(+1) }

    context 'and active job is created' do
      it { is_expected.to have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
      it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(data[:id]) }
      it { is_expected.to have_enqueued_job(Jobs::Notification).with(data[:id]) }
    end

    context 'and user trips_count updated' do
      it { is_expected.to change { user.reload.trips_count }.from(0).to(1) }
    end

    context 'when user_id is empty' do
      let(:data) { trip_params.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user turn off search car notification' do
      let(:user) { create(:user, notification_settings: [Constants::User::SEARCH_CAR]) }

      it { is_expected.not_to raise_error(Events::InvalidParamsError) }
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
      let(:entrance) { rand(5) }
      let(:msg) { I18n.t('trips.entrance', val: entrance) }

      before { subject.call }

      let(:data) { trip_params.merge(entrance: entrance).except(:comment) }

      it { expect(Trip.last.comment).to eq(" #{msg}") }

      context 'and add comment' do
        let(:data) { trip_params.merge(entrance: entrance, comment: 'FooBar') }

        it { expect(Trip.last.comment).to eq("FooBar #{msg}") }
      end
    end

    # context 'when payment by bonus' do
    #   let!(:bonus_trip) { create(:bonus_trip, user_id: user.id, status: :fresh, type: Constants::BonusTrip::GIFT) }
    #   let(:data) { trip_params.merge(bonus: true) }

    #   before { allow_any_instance_of(Directions).to receive(:distance) { 5_000 } }

    #   it { is_expected.to change { Payment.count }.by(+1) }
    #   it { is_expected.to change { bonus_trip.reload.used? }.to be_truthy }

    #   context 'but bonus was used before' do
    #     before { bonus_trip.used! }

    #     it { is_expected.to raise_error(Events::InvalidParamsError) }
    #   end

    #   context 'when bonus more than 10 km' do
    #     before { allow_any_instance_of(Directions).to receive(:distance) { 15_000 } }

    #     it { is_expected.to raise_error(Events::InvalidParamsError) }
    #   end

    #   context 'and cashback param present' do
    #     let(:data) { trip_params.merge(bonus: true, cashback: true) }

    #     it { is_expected.to change { BonusTrip.count }.by(+1) }

    #     context 'but user have fresh cashback bonus trip' do
    #       let!(:bonus_trip) { create(:bonus_trip, user_id: user.id, status: :fresh, type: Constants::BonusTrip::CASHBACK) }

    #       it { is_expected.not_to change { BonusTrip.count } }
    #       it { is_expected.to change { bonus_trip.reload.used? }.to be_truthy }
    #     end
    #   end
    # end

    context 'when user have pending payments' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user already has pending trip' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::PENDING) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when delivery trip' do
      before {
        allow_any_instance_of(described_class).to receive(:assign_trip_to_order_payment) { true }
      }

      let!(:vendor) { create(:vendor) }
      let!(:order) { create(:order, user_id: user.id, vendor_id: vendor.id) }
      let(:data) { trip_params.merge(delivery: true, time: 15.minutes.since.strftime('%H:%M'), order_id: order.id) }

      it { is_expected.to_not have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
      it { is_expected.to_not have_enqueued_job(Jobs::DeclineTrip).with(data[:id]) }
    end

    context "when delivery trip don't need vendor approval" do
      before {
        allow_any_instance_of(described_class).to receive(:assign_trip_to_order_payment) { true }
      }

      let!(:vendor) { create(:vendor, need_approve: false) }
      let!(:order) { create(:order, user_id: user.id, vendor_id: vendor.id) }
      let(:data) { trip_params.merge(delivery: true, time: 15.minutes.since.strftime('%H:%M'), order_id: order.id) }

      it { is_expected.to_not have_enqueued_job(Jobs::TelegramNotification).with(data[:id]) }
      it { is_expected.to have_enqueued_job(Jobs::SearchCarForTrip).with(data[:id]) }
      it { is_expected.to_not have_enqueued_job(Jobs::DeclineTrip).with(data[:id]) }

      context 'comment includes order details' do
        before { subject.call }

        let(:amount) { "Сума: #{order.amount}" }
        let(:item) { "Товари: #{eval(order.items.values[0])['name']} - #{eval(order.items.values[0])['quantity']}" }

        it { expect(Trip.last.comment).to include(amount) && include(item) }
      end
    end
  end
end
