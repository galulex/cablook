describe Events::Cars::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { attributes_for(:car) }

    it { is_expected.to change { Car.count }.by(+1) }

    context 'when number is empty' do
      let(:data) { attributes_for(:car).except(:number) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when number is already exist' do
      before { create(:car, number: data[:number]) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
