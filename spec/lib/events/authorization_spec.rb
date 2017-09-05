describe Events::Authorization do
  describe '.call' do
    let(:result) { described_class.call(data) }
    let!(:user) { Factory[:user] }
    let(:data) do
      {
        phone_number: user.phone_number,
        password: '12341234'
      }
    end

    it { expect(result).not_to be nil }
    it { expect(result.phone_number).to eq(user.phone_number) }

    context 'when data is invalid' do
      subject { -> { result } }

      let(:data) { { email: user.email, password: Faker::Internet.password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
