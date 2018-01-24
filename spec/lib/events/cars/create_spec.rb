describe Events::Cars::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:car].to_h }

    it { is_expected.to change { car_repository.all.count }.by(+1) }

    context 'when number is empty' do
      let(:data) { Factory.structs[:car].to_h.except(:number) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
