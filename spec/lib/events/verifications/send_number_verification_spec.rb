describe Events::Verifications::SendNumberVerification do
  describe '.call' do
    subject { -> { described_class.call(number: phone_number) } }

    let!(:user) { Factory[:user] }
    let(:phone_number) { user.phone_number }

    before { allow_any_instance_of(described_class).to receive(:send_verification_code) }

    it { is_expected.to change { users_repository.by_phone_number(user.phone_number).verification_token }.from(nil) }

    context 'when user does not exist' do
      let(:phone_number) { "+#{Faker::Number.number(12)}" }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
