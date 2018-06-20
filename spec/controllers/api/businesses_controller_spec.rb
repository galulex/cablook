describe Api::BusinessesController, type: :controller do
  let(:phone_number) { '+380932225665' }
  let(:auth_token) { user.auth_token }
  let(:user) { create(:user, phone_number: phone_number) }
  let(:card) { create(:card, user_id: user.id) }
  let(:params) { { business: business_params } }
  let(:business_params) { { card_id: card.id, email: 'contact@cablook.taxi', name: 'CabLook', employees: [phone_number] } }

  before { request.headers['Auth-Token'] = auth_token }

  subject { response }

  describe '#create' do
    before { post :create, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:business_params) { { name: '' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#update' do
    before { patch :update, params: params, as: :json }

    it { is_expected.to be_successful }

    context 'when params are invalid' do
      let(:business_params) { { name: '' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#show' do
    before do
      user.create_business(business_params)
      get :show, as: :json
    end

    it { is_expected.to be_successful }
  end

  describe '#destroy' do
    before { delete :destroy, as: :json }

    it { is_expected.to be_successful }
  end
end
