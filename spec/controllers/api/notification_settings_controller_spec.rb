describe Api::NotificationSettingsController, type: :controller do
  let(:user) { create(:user, auth_token: 'token') }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#update' do
    let(:notification_settings) { Constants::User::NOTIFICATIONS - [Constants::User::ACCEPT_TRIP] }

    context 'notification settings' do
      subject { response }

      let(:params) { { notification_settings: notification_settings } }
      before { patch :update, params: params }

      it { is_expected.to be_successful }
    end
  end
end

