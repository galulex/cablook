describe Events::Users::Authorize do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:user) { create(:user) }
    let(:data) { { phone_number: user[:phone_number] } }

    it { expect(result).not_to be nil }
    it { expect(result.phone_number).to eq(user.phone_number) }

    context 'when phone_number is invalid' do
      let(:data) { { phone_number: Faker::Number.number(12), password: user.encrypted_password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'user custom_iphone?' do
      let(:data) { { phone_number: '+380936977929', password: user.encrypted_password } }

      it { is_expected.not_to change{ user.reload.verification_token } }
      it { is_expected.not_to have_enqueued_job(Jobs::Sms) }
    end
    context 'when user will create' do
      let!(:user) { attributes_for(:user) }

      it { is_expected.to change { User.count }.by(+1) }
    end
  end
end
