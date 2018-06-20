describe Operations::UpdateUserDevice do
  describe '.call' do
    subject { -> { described_class.call(user.id, device_params) } }

    let(:user) { create(:user) }
    let(:device_params) { {} }

    context 'when do nothing' do
      let(:device_params) { { token: device.token, platform: device.platform } }
      let(:device) { create(:device, user_id: user.id) }

      it { is_expected.not_to change { device.reload.token } }
    end

    context 'when device will be updated' do
      let(:device) { create(:device, user_id: user.id) }
      let(:device_params) { { token: device.token + 'test', platform: device.platform } }

      it { is_expected.to change { device.reload.token } }
    end

    context 'when device will be created' do
      let(:device_params) { attributes_for(:device) }

      it { is_expected.to change { Device.count }.by(+1) }
    end
  end
end
