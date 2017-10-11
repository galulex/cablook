describe Repositories::User do
  describe '#all' do
    let(:instance) { described_class.new.all }

    it { expect(instance).to be_empty }

    context 'when users are found' do
      let!(:user) { Factory[:user] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_email' do
    let(:instance) { described_class.new.by_email(email) }
    let!(:user) { Factory[:user] }
    let(:email) { user.email }

    it { expect(instance.email).to eq(email) }

    context 'when user did not found' do
      let(:email) { user.email + 'test' }

      it { expect(instance).to be nil }
    end
  end

  describe '#by_token' do
    let(:instance) { described_class.new.by_token(auth_token) }
    let(:user) { Factory[:user] }
    let(:auth_token) { user.auth_token }

    it { expect(instance.auth_token).to eq(auth_token) }

    context 'when user did not found' do
      let(:auth_token) { user.auth_token + 'test' }

      it { expect(instance).to be nil }
    end
  end
end
