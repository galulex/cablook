describe Events::Trips::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { create(:trip, user_id: user.id) }
    let(:trip_params) { attributes_for(:trip, user_id: user.id, id: trip.id) }
    let(:data) { trip_params }
    let(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }
    let!(:price) { Price.create }

    context 'when departure is empty' do
      let(:data) { trip_params.except(:departure) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when destination is empty' do
      let(:data) { trip_params.except(:destination) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when departure_address is empty' do
      let(:data) { trip_params.except(:departure_address) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when destination_address is empty' do
      let(:data) { trip_params.except(:destination_address) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when path is empty' do
      let(:data) { trip_params.except(:path) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when distance is empty' do
      let(:data) { trip_params.except(:distance) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when duration is empty' do
      let(:data) { trip_params.except(:duration) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when payment by bonus' do
      context 'and distance greater than MAX_BONUS_DISTANCE' do
        let(:data) { trip_params.merge(distance: Constants::Trip::MAX_BONUS_DISTANCE + 1, bonus: true) }

        before { Settings.get.update!(bonuses: true) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end

      context 'and distance less than MAX_BONUS_DISTANCE' do
        let(:data) { trip_params.merge(distance: Constants::Trip::MAX_BONUS_DISTANCE - 1, bonus: true) }

        let!(:bonus_trip) do
          create(:bonus_trip, user_id: user.id, status: Constants::BonusTrip::USED, trip_id: trip.id)
        end
        let!(:trip_payment) do
          create(:trip_payment, status: Constants::Payments::BONUS, amount: 0, trip: trip, user: user)
        end

        it { is_expected.to change { trip.reload.cost } }
        it { is_expected.to change { trip.reload.path } }
        it { is_expected.to change { trip.reload.departure }.to(data[:departure].map(&:to_s)) }
        it { is_expected.to change { trip.reload.destination }.to(data[:destination].map(&:to_s)) }
        it { is_expected.to change { trip.reload.departure_address }.to(data[:departure_address]) }
        it { is_expected.to change { trip.reload.destination_address }.to(data[:destination_address]) }

        context 'and broadcast to channel' do
          it do
            expect(ActionCable.server).to receive(:broadcast).with(
              "#{Constants::Channels::TRIP}_#{trip.id}",
              hash_including(action: Constants::BroadcastActions::TRIP_UPDATED)
            )
            subject.call
          end
        end
      end
    end

    context 'when payment by card' do
      context 'and bonus trip is missing' do
        let!(:trip_payment) do
          create(:trip_payment, status: Constants::Payments::PENDING, amount: 12, trip: trip, user: user, card: card)
        end

        context 'and distance greater than MAX_DISTANCE' do
          let(:data) { trip_params.merge(distance: Constants::Trip::MAX_DISTANCE + 1, bonus: false) }

          it { is_expected.to raise_error(Events::InvalidParamsError) }
        end

        context 'and distance less than MAX_DISTANCE' do
          let(:data) { trip_params.merge(distance: Constants::Trip::MAX_DISTANCE - 1, bonus: false) }

          context 'and broadcast to channel' do
            it do
              expect(ActionCable.server).to receive(:broadcast).with(
                "#{Constants::Channels::TRIP}_#{trip.id}",
                hash_including(action: Constants::BroadcastActions::TRIP_UPDATED)
              )
              subject.call
            end
          end

          it { is_expected.to change { trip_payment.reload.amount } }
          it { is_expected.to change { trip.reload.cost } }
          it { is_expected.to change { trip.reload.path } }
          it { is_expected.to change { trip.reload.departure }.to(data[:departure].map(&:to_s)) }
          it { is_expected.to change { trip.reload.destination }.to(data[:destination].map(&:to_s)) }
          it { is_expected.to change { trip.reload.departure_address }.to(data[:departure_address]) }
          it { is_expected.to change { trip.reload.destination_address }.to(data[:destination_address]) }
        end
      end

      context 'and bonus trip is present' do
        let!(:trip_payment) do
          create(:trip_payment, status: Constants::Payments::BONUS, amount: 0, trip: trip, user: user)
        end
        let!(:bonus_trip) do
          create(:bonus_trip, user_id: user.id, status: Constants::BonusTrip::USED, trip_id: trip.id)
        end

        context 'and distance greater than MAX_DISTANCE' do
          let(:data) { trip_params.merge(distance: Constants::Trip::MAX_DISTANCE + 1) }

          it { is_expected.to raise_error(Events::InvalidParamsError) }
        end

        context 'and distance less than MAX_DISTANCE' do
          let(:data) { trip_params.merge(distance: Constants::Trip::MAX_DISTANCE - 1) }
          let(:order_reference) { "cablook_test_trip_#{trip.id}" }

          context 'and broadcast to channel' do
            it do
              expect(ActionCable.server).to receive(:broadcast).with(
                "#{Constants::Channels::TRIP}_#{trip.id}",
                hash_including(action: Constants::BroadcastActions::TRIP_UPDATED)
              )
              subject.call
            end
          end

          before { allow_any_instance_of(described_class).to receive(:order_reference).and_return(order_reference) }

          it { is_expected.to change { trip_payment.reload.amount } }
          it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::PENDING) }
          it { is_expected.to change { trip_payment.reload.card_id }.to(card.id) }
          it { is_expected.to change { trip_payment.reload.order_reference }.to(order_reference) }

          it { is_expected.to change { bonus_trip.reload.fresh? }.to be_truthy }
          it { is_expected.to change { bonus_trip.reload.trip_id }.to(nil) }

          it { is_expected.to change { trip.reload.cost } }
          it { is_expected.to change { trip.reload.path } }
          it { is_expected.to change { trip.reload.departure }.to(data[:departure].map(&:to_s)) }
          it { is_expected.to change { trip.reload.destination }.to(data[:destination].map(&:to_s)) }
          it { is_expected.to change { trip.reload.departure_address }.to(data[:departure_address]) }
          it { is_expected.to change { trip.reload.destination_address }.to(data[:destination_address]) }
        end
      end
    end

    context 'when payment system Fondy' do
      let(:reverse_stub) { double(Fondy::Reverse, call: { reverse_status: 'approved' }) }
      let(:recurring_stub) { double(Fondy::Recurring, call: { response_status: 'success' } ) }
      let(:order_reference) { 'test_order_reference' }
      let(:trip) { create(:trip, user_id: user.id) }
      let!(:trip_payment) { create(:trip_payment, trip_id: trip.id, user_id: user.id, order_reference: order_reference) }
      let(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
      let(:reverse_params) { [trip.cost, trip.trip_payment.order_reference] }
      let(:recurring_params) { [trip.user, data[:cost], card.token, order_reference, true] }

      before do
         Settings.get.update(payment_system: :fondy)

         allow_any_instance_of(described_class).to receive(:order_reference).and_return(order_reference)

         allow(Fondy::Reverse).to receive(:new).with(*reverse_params).and_return(reverse_stub)
         allow(Fondy::Recurring).to receive(:new).with(*recurring_params).and_return(recurring_stub)
      end

      it { is_expected.to change { trip_payment.reload.amount } }
      it { is_expected.to change { trip.reload.cost } }
      it { is_expected.to change { trip.reload.path } }
      it { is_expected.to change { trip.reload.departure }.to(data[:departure].map(&:to_s)) }
      it { is_expected.to change { trip.reload.destination }.to(data[:destination].map(&:to_s)) }
      it { is_expected.to change { trip.reload.departure_address }.to(data[:departure_address]) }
      it { is_expected.to change { trip.reload.destination_address }.to(data[:destination_address]) }

      context 'cancel previous hold amount and hold updated trip cost' do
        before { subject.call }

        it { (expect(Fondy::Reverse).to have_received(:new).with(*reverse_params).once) }
        it { (expect(Fondy::Recurring).to have_received(:new).with(*recurring_params).once) }
      end

      context 'and cant hold updated trip amount' do
        let(:recurring_stub) { double(Fondy::Recurring, call: { response_status: 'failed' }) }

        it { is_expected.to raise_error Events::InvalidParamsError }
      end

      context 'and cant unhold previous amount' do
        let(:reverse_stub) { double(Fondy::Reverse, call: { reverse_status: 'failed' }) }

        it { is_expected.to raise_error Events::InvalidParamsError }
      end
    end
  end
end
