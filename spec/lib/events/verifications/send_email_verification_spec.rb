describe Events::Verifications::SendEmailVerification do
  describe '.call' do
    subject { -> { described_class.call(email: email) } }

    let!(:user) { Factory[:user, confirmation_token: 'token'] }
    let(:email) { user.email }
    let(:token) { user.confirmation_token }

    before { allow_any_instance_of(described_class).to receive(:send_confirmation_link) }

    it { is_expected.to change { user_repository.by_email(user.email).confirmation_token }.from(token) }

    context 'when user does not exist' do
      let(:email) { "+#{Faker::Internet.email}" }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user exists with confirmed email' do
      let!(:user) { Factory[:user] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
