describe Events::Authorization do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:user) { Factory[:user] }
    let(:data) { { phone_number: user.phone_number, password: '12341234' } }

    it { expect(result).not_to be nil }
    it { expect(result.phone_number).to eq(user.phone_number) }

    context 'when phone_number is invalid' do
      let(:data) { { phone_number: Faker::Number.number(12), password: user.encrypted_password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when password is invalid' do
      let(:data) { { phone_number: user.phone_number, password: Faker::Internet.password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
