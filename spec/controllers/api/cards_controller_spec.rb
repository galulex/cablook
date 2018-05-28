describe Api::CardsController, type: :controller do
  let(:user) { Factory[:user, auth_token: 'token'] }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    let!(:user) { User.create(phone_number: '+380632225665', auth_token: 'token') }
    let!(:personal_card) { Card.create(user_id: user.id, pan: '0000****1234', token: :token, type: :Visa, currency: :UAH) }

    before { allow_any_instance_of(Api::ApiApplicationController).to receive(:current_user).and_return(user) }

    subject { JSON.parse(response.body) }

    context 'personal cards' do
      before { get :index, as: :json }

      it 'returns all cards' do
        expect(subject.size).to eql(1)
      end
    end

    context 'business' do
      let!(:owner) { User.create(phone_number: '+380502225665') }
      let!(:business_card) { Card.create(user_id: owner.id, pan: '0000****1111', token: :token, type: :Visa, currency: :UAH) }
      let!(:business) { Business.create(name: 'CabLook', email: 'contact@cablook.taxi', card_id: business_card.id, user_id: owner.id, users: [user]) }

      before { get :index, as: :json }

      it 'returns personal and business cards' do
        expect(subject.size).to eql(2)
      end
    end
  end

  describe '#create' do
    subject { response }

    let(:params) { JSON.parse(File.read('spec/fixtures/card_callback.json')) }

    before { post :create, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { super().merge(recToken: nil) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#delete' do
    subject { response }

    let(:params) { { id: card.id } }
    let(:card) { Factory[:card, user_id: user.id] }

    before { delete :destroy, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { { id: 999 } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
