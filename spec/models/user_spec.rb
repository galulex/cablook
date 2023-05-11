require 'spec_helper'

RSpec.describe User, type: :model do
  describe '#fondy?' do
    subject { user.fondy? }

    let(:user) { create(:user, phone_number: '+380987654321') }

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
