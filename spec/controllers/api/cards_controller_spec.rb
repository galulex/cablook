describe Api::CardsController, type: :controller do
  subject { response }

  let(:user) { create(:user, id: 1) }
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
      let!(:owner) { create(:user, phone_number: '+380502225665', id: 2) }
      let!(:business_card) { create(:card, user_id: owner.id) }
      let!(:business) { Business.create(name: 'CabLook', email: 'contact@cablook.taxi', card_id: business_card.id, user_id: owner.id, users: [user]) }

      before { get :index, as: :json }

      it 'returns personal and business cards' do
        expect(subject.size).to eql(2)
      end
    end

    context 'personal cards with older paysystem' do
      let!(:personal_card) { create(:card, user_id: user.id, payment_system: nil) }
      before { get :index, as: :json }

      it 'returns all cards' do
        expect(subject.size).to eql(0)
      end
    end
  end

  describe '#new' do
    let(:link){ JSON.parse(File.read('spec/fixtures/fondy/card_verify_success_response.json'))['response']['checkout_url'] }

    before { get :new, params: { user_id: user.id } }

    it { expect(JSON.parse(response.body)['response']['checkout_url']).to eq(link) }
    it { expect(response.status).to eq(200) }

    context 'when something went wrong' do
      let(:stub_verify) { double(call: failure_response) }
      let(:failure_response) { { response: { response_status: 'failure' } }.to_json }

      before do
        allow(Fondy::Verify).to receive(:new).and_return(stub_verify)
        get :new, params: { user_id: user.id } 
      end

      it { expect(JSON.parse(response.body)['response']['response_status']).to eq('failure') }
    end
  end

  describe '#complete' do
    let(:response_data) { JSON.parse(File.read('spec/fixtures/fondy/create_callback.json')) }
    let(:card_token) { response_data['rectoken'] }

    before { post :complete, params: response_data }

    it { expect(response).to redirect_to(root_path) }
    it { expect(user.cards.last.token).to eq(card_token) }

    context 'when recToken already exsist' do
      let(:card) { create(:card, token: response_data['rectoken']) }

      it { expect(response).to redirect_to(root_path) }
    end

    context 'when params are empty' do
      before { post :complete, params: {} }

      it { expect(JSON.parse(response.body)['errors']).to include(match(/masked_card/)) }
      it { expect(JSON.parse(response.body)['errors']).to include(match(/card_type/)) }
      it { expect(JSON.parse(response.body)['errors']).to include(match(/currency/)) }
      it { expect(JSON.parse(response.body)['errors']).to include(match(/rectoken/)) }
      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect{ user.cards.size }.not_to change {} }
    end

    context 'when only one parameter' do
      before { post :complete, params: { masked_card: '444455XXXXXX1111' } }
      it { expect(JSON.parse(response.body)['errors']).to_not be_nil }
      it { is_expected.to have_http_status(:unprocessable_entity) }

    end

    context 'when recToken is empty' do
      before { post :complete, params: { masked_card: '444455XXXXXX1111', card_type: 'VISA', currency: 'UAH', rectoken: '' } }

      it { expect(JSON.parse(response.body)['errors']).to include(match(/rectoken/)) }
      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when there are no required params' do
      before { post :complete, params: { cardPan: '1111000099998888', currency: 'UAH' } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
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
