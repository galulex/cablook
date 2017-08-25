describe Validators::User do
  describe 'email must be unique' do
    subject { described_class.new(data).validate }

    let(:data) { Factory.structs[:user] }

    it { is_expected.to be true }

    context 'when user with this email already exist' do
      let!(:user) { Factory[:user] }
      let(:data) { { email: user.email } }

      it { is_expected.to be false }
    end
  end
end
