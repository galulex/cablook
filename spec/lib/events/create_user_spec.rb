describe Events::CreateUser do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { Factory.structs[:user].to_h.except(:id) }

    before { allow(Events::Verifications::SendNumberVerification).to receive(:call) { '1111' } }

    it { is_expected.to change { users_repository.all.count }.by(+1) }

    context 'when email is invalid' do
      let(:data) { Factory.structs[:user, email: Faker::Name.name].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when phone_number is invalid' do
      let(:data) { Factory.structs[:user, phone_number: Faker::Number.number(1)].to_h.except(:id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'and user is not verified' do
      subject { instance.verification_token }
      let(:instance) { described_class.call(data) }

      it { is_expected.not_to be nil }
      it { is_expected.to eq('1111') }
    end
  end
end
