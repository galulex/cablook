describe Users::Validator do
  describe 'email must be unique' do
    subject { described_class.new(data).validate }

    let(:user_attrs) { Factory.structs[:user] }
    let(:data) { user_attrs }

    it { is_expected.to be true }

    context 'when user with this email already exist' do
      let!(:user) { Factory[:user] }
      let(:data) { { email: user.email } }

      it { is_expected.to be false }
    end
  end
end
