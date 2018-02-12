describe Events::AuthorizeUser do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:user) { Factory[:user] }
    let(:data) { { phone_number: user.phone_number } }

    it { expect(result).not_to be nil }
    it { expect(result.phone_number).to eq(user.phone_number) }

    context 'when phone_number is invalid' do
      let(:data) { { phone_number: Faker::Number.number(12), password: user.encrypted_password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user will create' do
      let!(:user) { Factory.structs[:user] }

      it { is_expected.to change { user_repository.users.count }.by(+1) }
    end
  end
end
