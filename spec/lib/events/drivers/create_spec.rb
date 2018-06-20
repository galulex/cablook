describe Events::Drivers::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { attributes_for(:driver) }

    it { is_expected.to change { Driver.count }.by(+1) }

    context 'when name is empty' do
      let(:data) { attributes_for(:driver).except(:name) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when username is empty' do
      let(:data) { attributes_for(:driver).except(:username) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when username is already exists' do
      before { create(:driver, username: data[:username]) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
