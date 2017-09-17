describe Repositories::Driver do
  describe '#by_name' do
    let(:instance) { described_class.new.by_name(name) }
    let!(:driver) { Factory[:driver] }
    let(:name) { driver.name }

    it { expect(instance.name).to eq(name) }

    context 'when driver do not found' do
      let(:name) { driver.name + 'test' }

      it { expect(instance).to be nil }
    end
  end

  describe '#by_token' do
    let(:instance) { described_class.new.by_token(auth_token) }
    let(:driver) { Factory[:driver] }
    let(:auth_token) { driver.auth_token }

    it { expect(instance.auth_token).to eq(auth_token) }

    context 'when driver do not found' do
      let(:auth_token) { driver.auth_token + 'test' }

      it { expect(instance).to be nil }
    end
  end
end
