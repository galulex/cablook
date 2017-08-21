describe Events::CreateUser do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:user].to_h.except(:id) }

    it { is_expected.to change { users_repository.all.count }.by(+1) }

    context 'when data is invalid' do
      let(:data) { Factory.structs[:user, email: Faker::Name.name].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
