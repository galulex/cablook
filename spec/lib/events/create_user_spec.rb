describe Events::CreateUser do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:user].to_h.except(:id) }

    it { is_expected.to change { users_repository.all.count }.by(+1) }

    context 'when email is invalid' do
      let(:data) { Factory.structs[:user, email: Faker::Name.name].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when phone_number is invalid' do
      let(:data) { Factory.structs[:user, phone_number: Faker::Number.number(1)].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
