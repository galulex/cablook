describe SearchEngine::NearestPoint do
  describe '.call' do
    let(:shortest_route) { described_class.call(origins_location: origins, destination: destination) }

    let(:origins) { [origin_1, origin_2] }
    let(:origin_1) { [49.428908, 32.008248] } # Cherkasy South side
    let(:origin_2) { [49.449907, 32.064315] } # Cherkasy Valley of roses
    let(:destination) { [49.441655, 32.065358] } # Cherkasy center town

    context 'when request success and with in traffic' do
      before { stub_request(:any, /maps.googleapis.com/).to_return body: recorded_request_for(:success_with_in_traffic) }

      it { expect(shortest_route.origin.lat).to eq(origin_1[0]) }
      it { expect(shortest_route.origin.lng).to eq(origin_1[1]) }
      it { expect(shortest_route.duration_in_seconds).not_to be nil }
    end

    context 'when request success' do
      # TODO
      before { stub_request(:any, /maps.googleapis.com/).to_return body: recorded_request_for(:success) }
    end

    context 'when request is zero' do
      # TODO
      before { stub_request(:any, /maps.googleapis.com/).to_return body: recorded_request_for(:zero_result) }
    end
  end
end
