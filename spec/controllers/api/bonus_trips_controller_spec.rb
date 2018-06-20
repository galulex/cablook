describe Api::BonusTripsController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    before do
      trip = create(:trip, user_id: user.id)
      create(:bonus_trip, trip_id: trip.id, user_id: user.id)
      get :index, as: :json
    end

    it_behaves_like 'authorization_required'

    it { is_expected.to be_successful }
  end
end
