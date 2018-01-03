describe Events::Verifications::VerifyEmail do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { email: user.email, token: token } }
    let!(:user) { Factory[:user, confirmation_token: token] }
    let(:token) { '1111' }

    it { is_expected.to change { user_repository.by_email(user.email).confirmation_token }.from(token).to(nil) }

    context 'when user does not exist' do
      let(:data) { { email: "+#{Faker::Internet.email}", token: token } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when token is invalid' do
      let(:data) { { email: user.email, token: '0000' } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
