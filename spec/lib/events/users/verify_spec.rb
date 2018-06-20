describe Events::Users::Verify do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:user) { create(:user) }
    let(:data) { { phone_number: user.phone_number, token: user.verification_token } }

    it { is_expected.to change { user.reload.verification_token }.to(nil) }

    context 'when user not found' do
      let(:data) { { phone_number: user.phone_number, token: 'test-test-test' } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
