describe Events::CreateDriver do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:driver].to_h }

    it { is_expected.to change { drivers_repository.all.count }.by(+1) }

    context 'when name is empty' do
      let(:data) { Factory.structs[:driver].to_h.except(:name) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when username is empty' do
      let(:data) { Factory.structs[:driver].to_h.except(:username) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
