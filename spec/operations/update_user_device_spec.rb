describe Operations::UpdateUserDevice do
  describe '.call' do
    subject { -> { described_class.call(user.id, device_params) } }

    let(:user) { Factory[:user] }
    let(:device_params) { {} }

    context 'when do nothing' do
      let(:device_params) { { token: device.token, platform: device.platform } }
      let(:device) { Factory[:device, user_id: user.id] }

      it { is_expected.not_to change { device_repository.by_id(device.id).token } }
    end

    context 'when device will be updated' do
      let(:device) { Factory[:device, user_id: user.id] }
      let(:device_params) { { token: device.token + 'test', platform: device.platform } }

      it { is_expected.to change { device_repository.by_id(device.id).token } }
    end

    context 'when device will be created' do
      let(:device) { Factory.structs[:device] }
      let(:device_params) { { token: device.token, platform: device.platform } }

      it { is_expected.to change { device_repository.devices.count }.by(+1) }
    end
  end
end
