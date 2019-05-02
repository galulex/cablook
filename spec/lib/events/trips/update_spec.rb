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
          it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::PENDING) }
          it { is_expected.to change { trip_payment.reload.card_id }.to(card.id) }
          it { is_expected.to change { trip_payment.reload.order_reference }.to("cablook_test_trip_#{trip.id}") }

          it { is_expected.to change { bonus_trip.reload.status }.to(Constants::BonusTrip::NEW) }
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
  end
end
