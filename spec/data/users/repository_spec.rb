describe Users::Repository do
  describe '#by_email' do
    let(:instance) { described_class.new.by_email(email) }
    let!(:user) { Factory[:user] }
    let(:email) { user.email }

    it { expect(instance.email).to eq(user.email) }

    context 'when user do not found' do
      let(:email) { user.email + 'test' }

      it { expect(instance).to be nil }
    end
  end
end
