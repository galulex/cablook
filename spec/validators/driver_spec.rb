describe Validators::Driver do
  describe 'username must be unique' do
    subject { described_class.new(data).validate }

    let(:data) { Factory.structs[:driver] }

    it { is_expected.to be true }

    context 'when driver does not have name' do
      let(:data) { Factory.structs[:driver].to_h.except(:name) }

      it { is_expected.to be false }
    end

    context 'when driver does not have username' do
      let(:data) { Factory.structs[:driver].to_h.except(:username) }

      it { is_expected.to be false }
    end

    context 'when driver with this username already exists' do
      let!(:driver) { Factory[:driver] }
      let(:data) { { username: driver.username } }

      it { is_expected.to be false }
    end
  end
end
