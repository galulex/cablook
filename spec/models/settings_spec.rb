require 'spec_helper'

RSpec.describe Settings, type: :model do
  describe '#is_allowed_for_fondy?' do
    subject { Settings.get.is_allowed_for_fondy?(user.phone_number) }

    let(:user) { build(:user, phone_number: '+380987654321') }

    context 'when allowed users nil' do
      before { Settings.get.update!(allowed_users: nil) }

      it { is_expected.to be_falsey }
    end

    context 'when allowed for all users' do
      before { Settings.get.update!(allowed_users: Settings::ALLOW_FONDY_FOR_ALL_USERS) }

      it { is_expected.to be_truthy }
    end

    context 'when not allowed' do
      before { Settings.get.update!(allowed_users: '+380987654322') }

      it { is_expected.to be_falsey }
    end
  end
end
