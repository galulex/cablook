describe Api::SettingsController, type: :controller do
  describe '#show' do
    context 'settings for authorized user' do
      let(:user) { create(:user) }
      let(:auth_token) { user.auth_token }
      let(:expected_keys) { %w[bonuses cashback delivery validate_unpaid_trips email_auth] }

      before do
        request.headers['Auth-Token'] = auth_token
        post :show
      end

      it { expect(response).to be_successful }
      it { expect(JSON.parse(response.body).keys).to include(*expected_keys) }
    end

    context 'settings for unauthorized user' do
      let(:expected_keys) { %w[email_auth] }

      before { post :show }

      it { expect(response).to be_successful }
      it { expect(JSON.parse(response.body).keys).to include(*expected_keys) }
    end
  end
end
