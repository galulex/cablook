describe Api::TripsController, type: :controller do
  let(:user) { create(:user) }
  let!(:card) { create(:card, user_id: user.id) }
  let(:auth_token) { user.auth_token }
  let(:wayforpay_body) { { reasonCode: 1100 }.to_json }

  before(:all) { Price.create }

  before do
    request.headers['Auth-Token'] = auth_token
    allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) }
  end

  describe '#create' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:params) { { trip: trip_params } }
    let(:trip_params) { attributes_for(:trip) }

    before { post :create, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:trip_params) { attributes_for(:trip).except(:path) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when pay by bonus' do
      let(:trip_params) { super().merge(bonus: true) }

      before do
        allow_any_instance_of(Directions).to receive(:distance) { distance }
      end

      context 'and distance less than MAX_BONUS_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_BONUS_DISTANCE - 1 }

        context 'bonus trip is present' do
          before do
            create(:bonus_trip, user_id: user.id, status: Constants::BonusTrip::NEW)
            post :create, params: params, as: :json
          end

          it { is_expected.to be_successful }
        end

        context 'bonus trip is missing' do
          it { is_expected.to have_http_status(406) }
        end
      end

      context 'and distance greater than MAX_BONUS_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_BONUS_DISTANCE + 1 }

        it { is_expected.to have_http_status(406) }
      end
    end

    context 'when user have pending payments' do
      let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      before { post :create, params: params, as: :json }

      it { is_expected.to have_http_status(418) }
    end
  end

  describe '#index' do
    subject { response }

    let(:params) { {} }

    before do
      trip = create(:trip, user_id: user.id)
      create(:feedback, trip_id: trip.id, user_id: trip.user_id)
      get :index, as: :json, params: params
    end

    it { is_expected.to be_successful }

    context 'with pagination' do
      let(:params) { { page: 1, per: 1 } }

      it { is_expected.to be_successful }
    end
  end

  describe '#show' do
    subject { response }

    let(:params) { { id: trip.id } }
    let(:trip) { create(:trip, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { get :show, params: params, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#cancel' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip_with_driver) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user_id) }

    before { patch :cancel, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when trip is finished' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#retry' do
    subject { response }

    let(:params) { { trip_id: trip.id } }
    let(:trip) { create(:trip) }

    before { patch :retry, params: params, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#edit' do
    subject { response }

    let(:params) { { id: trip.id } }
    let(:trip) { create(:trip, user_id: user.id) }

    before { get :edit, params: params, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#update' do
    subject { response }

    it_behaves_like 'authorization_required'

    let(:trip) { create(:trip, user: user) }
    let(:params) { { trip: trip_params.merge(id: trip.id), id: trip.id } }
    let(:trip_params) { attributes_for(:trip, bonus: false) }

    before do
      create(:trip_payment, trip: trip, user: user, card: card)
      patch :update, params: params, as: :json
    end

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:trip_params) { attributes_for(:trip).except(:departure) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when pay by bonus' do
      let(:trip_params) { super().merge(bonus: true) }

      before do
        allow_any_instance_of(Directions).to receive(:distance) { distance }
        create(:bonus_trip, user_id: user.id, status: Constants::BonusTrip::USED, trip_id: trip.id)
        patch :update, params: params, as: :json
      end

      context 'and distance less than MAX_BONUS_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_BONUS_DISTANCE - 1 }

        it { is_expected.to be_successful }
      end

      context 'and distance greater than MAX_BONUS_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_BONUS_DISTANCE + 1 }

        it { is_expected.to have_http_status(406) }
      end
    end

    context 'when pay by card' do
      before do
        allow_any_instance_of(Directions).to receive(:distance) { distance }
        patch :update, params: params, as: :json
      end

      context 'and distance less than MAX_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_DISTANCE - 1 }

        it { is_expected.to be_successful }
      end

      context 'and distance greater than MAX_DISTANCE' do
        let(:distance) { Constants::Trip::MAX_DISTANCE + 1 }

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end
  end
end
