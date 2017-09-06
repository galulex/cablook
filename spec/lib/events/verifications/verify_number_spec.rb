describe Events::Verifications::VerifyNumber do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { number: user.phone_number, token: token } }
    let!(:user) { Factory[:user, verification_token: token] }
    let(:token) { '1111' }

    it { is_expected.to change { users_repository.by_phone_number(user.phone_number).verification_token }.from(token).to(nil) }

    context 'when user does not exist' do
      let(:data) { { number: "+#{Faker::Number.number(12)}", token: token } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when token is invalid' do
      let(:data) { { number: user.phone_number, token: '0000' } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
