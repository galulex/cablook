describe Api::BusinessesController, type: :controller do
  let(:user) { User.create(phone_number: '+380932225665') }
  let(:params) { { business: business_params, auth_token: user.auth_token } }
  let(:business_params) { { card_id: card.id, email: 'contact@cablook.taxi', name: 'CabLook', employees: ['+380932225665'] } }
  let(:card) { Card.create(Factory.structs[:card].to_h.merge(user: user)) }

  before { allow_any_instance_of(Api::ApiApplicationController).to receive(:current_user).and_return(user) }
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
    before { get :show, as: :json }

    it { is_expected.to be_successful }
  end

  describe '#destroy' do
    before { delete :destroy, as: :json }

    it { is_expected.to be_successful }
  end
end
