describe Events::NotificationSettings::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    before { subject.call }

    let!(:notification_settings) { { notification_settings: Constants::User::NOTIFICATIONS - [Constants::User::ACCEPT_TRIP] } }
    let(:data) { notification_settings.merge(user_id: user.id) }
    let!(:user) { create(:user) }

    context 'when notification settings is updated successfully' do
      it { expect(user.reload.notification_settings).to eq [Constants::User::ACCEPT_TRIP] }
    end
  end
end

