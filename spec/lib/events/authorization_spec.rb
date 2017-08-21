describe Events::Authorization do
  describe '.call' do
    let(:result) { described_class.call(data) }
    let!(:user) { Factory[:user] }
    let(:data) { { email: user.email, password: '12341234' } }

    it { expect(result).not_to be nil }
    it { expect(result.email).to eq(user.email) }

    context 'when data is invalid' do
      subject { -> { result } }

      let(:data) { { email: user.email, password: Faker::Internet.password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
