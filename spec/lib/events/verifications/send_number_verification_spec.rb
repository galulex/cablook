describe Events::Verifications::SendNumberVerification do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:user) { create(:user) }
    let(:phone_number) { user.phone_number }
    let(:data) { { phone_number: phone_number } }

    it { is_expected.to have_enqueued_job(Jobs::Sms) }
    it { is_expected.to change { user.reload.verification_token } }

    context 'when user input invalid number' do
      let(:phone_number) { '+380001111111' }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
