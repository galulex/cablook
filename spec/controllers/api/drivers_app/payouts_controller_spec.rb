describe Api::DriversApp::PayoutsController, type: :controller do
  let(:driver) { create(:driver_with_car, balance: 100, card_number: '1234432111112222') }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#create' do
    subject { response }

    context 'when all is ok' do
      let(:amount) { 50 }

      before { post :create, params: { amount: amount } }

      it { is_expected.to be_successful }
      it { is_expected.to have_http_status(201) }
    end

    context 'when amount larger than driver balance' do
      let(:amount) { 101 }

      before { post :create, params: { amount: amount } }

      it { is_expected.to_not be_successful }
      it { is_expected.to have_http_status(422) }
    end
  end
end
