describe Api::PaymentsController, type: :controller do
  subject { response }

  let!(:user) { Factory[:user] }
  let(:auth_token) { user.auth_token }

  before do
    request.headers['Auth-Token'] = auth_token
    body = { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json
    allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: body) }
  end

  describe '#index' do
    let!(:payment) { Factory[:payment, user_id: user.id] }

    before { get :index, as: :json }

    it_behaves_like 'authorization_required'

    it { is_expected.to be_successful }
  end

  describe '#retry_pendings' do
    let(:params) { { card_id: card.id } }
    let(:card) { Factory[:card, user_id: user.id] }
    let!(:payment) { Factory[:payment, user_id: user.id, status: Constants::Payments::PENDING] }

    before { post :retry_pendings, params: params, as: :json }

    it { is_expected.to be_successful }
  end
end
