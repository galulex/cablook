describe Api::CardsController, type: :controller do
  let(:user) { create(:user, auth_token: 'token') }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    let!(:personal_card) { create(:card, user_id: user.id) }

    subject { JSON.parse(response.body)['cards'] }

    context 'personal cards' do
      before { get :index, as: :json }

      it 'returns all cards' do
        expect(subject.size).to eql(1)
      end
    end

    context 'business' do
      let!(:owner) { create(:user, phone_number: '+380502225665') }
      let!(:business_card) { create(:card, user_id: owner.id) }
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
      let(:params) { super().merge(cardPan: nil) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when status Declined' do
      let(:params) { super().merge(transactionStatus: 'Declined') }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#complete' do
    subject { response }

    before { post :complete, params: { orderReference: '1996', recToken: 'testToken', transactionStatus: 'Approved' } }

    it { is_expected.to redirect_to(root_path) }

    context 'when recToken already exsist' do
      let(:card) { create(:card, token: 'testToken') }

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when params are empty' do
      before { post :complete, params: {} }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when only one parameter' do
      before { post :complete, params: { orderReference: '1996' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when recToken is empty' do
      before { post :complete, params: { orderReference: '1996', recToken: '' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when there are no required params' do
      before { post :complete, params: { cardPan: '1111000099998888', currency: 'UAH' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when transactionStatus: Pending' do
      before { post :complete, params: { orderReference: '1996', recToken: '', transactionStatus: 'Pending' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when transactionStatus: Approved' do
      before { post :complete, params: { orderReference: '1996', recToken: 'testToken', transactionStatus: 'Approved' } }

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when transactionStatus: Refunded' do
      before { post :complete, params: { orderReference: '1996', recToken: 'testToken', transactionStatus: 'Refunded' } }

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when transactionStatus: Expired' do
      before { post :complete, params: { orderReference: '1996', recToken: 'testToken', transactionStatus: 'Expired' } }

      it { is_expected.to redirect_to(root_path) }
    end
  end

  describe '#delete' do
    subject { response }

    let(:params) { { id: card.id } }
    let(:card) { create(:card, user_id: user.id) }

    before { delete :destroy, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { { id: 999 } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
