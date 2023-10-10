RSpec.describe Jobs::SendNotify do
  describe '#perform' do
    let(:perform_now) { described_class.perform_now(options) }
    let(:notification_title) { 'CabLook' }
    let(:defaults_notification_params) { { sound: 'default' } }
    let(:ios_token) { 'ios_token' }
    let(:device_token) { 'sxu_T6oyECL2pfiyzXA1FPPiyOjENlToxRMnXQp640_aElkVwwL2pfiyzXA1FPP' }
    let(:user) { create(:user) }
    let(:options) { { uk: 'text', user_id: user.id } }
    let(:notification_params) { { body: options[user.locale.to_sym], title: notification_title } }
    let(:expected_params) { { notification: defaults_notification_params.merge(notification_params) } }
    let(:fcm_double) { double(FCM, send: {}) }

    before { allow(FCM).to receive(:new).and_return(fcm_double) }

    context 'when user dont have any device' do
      it { expect(fcm_double).not_to have_received(:send) }
    end

    context 'when user have ios device' do
      before do
        user.devices.create(token: ios_token, platform: Constants::Device::IOS_FCM)
        perform_now
      end

      it { expect(fcm_double).to have_received(:send).with([ios_token], expected_params).once }
    end

    context 'when user have not ios device' do
      before do
        user.devices.create(token: device_token, platform: 'any platform')
        perform_now
      end

      it { expect(fcm_double).to have_received(:send).with([device_token], expected_params).once }
    end

    context 'when user have ios and other device' do
      before do
        user.devices.create(token: ios_token, platform: Constants::Device::IOS_FCM)
        user.devices.create(token: device_token, platform: 'any platform')
        perform_now
      end

      it do
        expect(fcm_double).to have_received(:send).with([device_token], expected_params).once
        expect(fcm_double).to have_received(:send).with([ios_token], expected_params).once
      end
    end
  end
end
