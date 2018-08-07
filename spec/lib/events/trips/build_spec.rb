describe Events::Trips::Build do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { attributes_for(:new_trip) }

    before do
      allow(Net::HTTP).to receive(:get_response).and_return(double(body: File.read('spec/fixtures/maps/success_directions')))
    end

    it { is_expected.not_to raise_error(Exception) }

    context 'no route' do
      before { allow(JSON).to receive(:parse).and_return('routes' => []) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
