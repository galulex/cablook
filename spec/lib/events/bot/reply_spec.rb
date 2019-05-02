describe Events::Bot::Reply do
  describe '#run' do
    subject { described_class.new(data) }
    let(:default_data) { { from: { username: 'name', language_code: 'en' }, chat: { id: 0 } } }
    let(:places_response) { double(location: { lat: 0, lng: 0 }) }
    let(:geokit_response) { double(street_address: 'street') }

    before do
      allow(Places).to receive(:new).and_return(places_response)
      allow(Geokit::Geocoders::GoogleGeocoder).to receive(:reverse_geocode).and_return(geokit_response)
    end

    after { subject.call }

    context 'start' do
      let(:data) { default_data.merge(text: '/start') }

      it { expect_any_instance_of(TelegramOrder).to receive(:perform).with('start') }
    end

    context 'book' do
      let(:data) { default_data.merge(text: '🚖 BOOK') }

      it { expect_any_instance_of(TelegramOrder).to receive(:perform).with('book') }
    end

    context 'departure address' do
      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('request_departure_address') }

      context 'attached location' do
        let(:data) { default_data.merge(text: '', location: { latitude: 1, longitude: 1 }) }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end

      context 'location from text input' do
        let(:data) { default_data.merge(text: 'address') }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end
    end

    context 'destination address' do
      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('request_destination_address') }

      context 'attached location' do
        let(:data) { default_data.merge(text: '', location: { latitude: 1, longitude: 1 }) }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end

      context 'location from text input' do
        let(:data) { default_data.merge(text: 'address') }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end
    end

    context 'waypoint address' do
      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('initial_waypoint') }

      context 'attached location' do
        let(:data) { default_data.merge(text: '', location: { latitude: 1, longitude: 1 }) }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end

      context 'location from text input' do
        let(:data) { default_data.merge(text: 'address') }

        it 'should update trip and reply' do
          expect_any_instance_of(TelegramOrder).to receive(:reply)
          expect_any_instance_of(TelegramOrder).to receive(:update_trip)
        end
      end
    end

    context 'comment' do
      let(:comment) { 'some comment' }
      let(:data) { default_data.merge(text: comment) }

      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('comment') }

      it 'should update comment and move to the next step' do
        expect_any_instance_of(TelegramOrder).to receive(:update_trip).with(comment: comment)
        expect_any_instance_of(TelegramOrder).to receive(:skip_comment)
      end
    end

    context 'rating' do
      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('rate_trip') }

      context 'valid rating' do
        let(:rating) { 1 }
        let(:data) { default_data.merge(text: rating) }

        it { expect_any_instance_of(TelegramOrder).to receive(:compose_feedback).with({ rate: rating }, :tips) }
      end

      context 'invalid rating' do
        let(:rating) { 0 }
        let(:data) { default_data.merge(text: rating) }

        it { expect_any_instance_of(TelegramOrder).to receive(:send_message).with(:incorrect_rating) }
      end
    end

    context 'tips' do
      before { allow_any_instance_of(TelegramOrder).to receive(:step).and_return('tips') }

      context 'valid tips' do
        let(:tips) { '5' }
        let(:data) { default_data.merge(text: tips) }

        it 'should accept tips' do
          expect_any_instance_of(TelegramOrder).to receive(:compose_feedback).with({ tip: tips.to_i }, :tips_accept)
          expect_any_instance_of(TelegramOrder).to receive(:create_feedback)
        end
      end

      context 'invalid tips' do
        let(:tips) { '111' }
        let(:data) { default_data.merge(text: tips) }

        it 'should not accept tips' do
          expect_any_instance_of(TelegramOrder).to_not receive(:compose_feedback)
          expect_any_instance_of(TelegramOrder).to receive(:create_feedback)
        end
      end
    end
  end
end
