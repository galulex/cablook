describe Api::ReferralsController, type: :controller do
  let!(:referrer) { create(:user) }
  let!(:user) { create(:user) }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before do
      create(:bonus_trip, user_id: user.id)
      create(:bonus_trip, friend_id: user.id, user_id: create(:user).id)
      get :index, as: :json
    end

    it { is_expected.to be_successful }
  end

  describe '#create' do
    subject { response }

    let(:params) { { referral_code: referrer.referral_code } }

    before { post :create, params: params, as: :json }

    it_behaves_like 'authorization_required'

    it { is_expected.to be_successful }

    context 'when referrer not found' do
      let(:params) { { referral_code: 'test' } }

      it { is_expected.to have_http_status(:not_found) }
    end

    context 'when referrer and referral the same users' do
      let(:user) { referrer }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
