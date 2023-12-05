describe Api::DriversApp::StatisticsController, type: :controller do
  let(:driver) { create(:driver) }
  let(:auth_token) { driver.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    subject { response }

    shared_examples 'success response' do
      it { is_expected.to be_successful }
      it { is_expected.to have_http_status(200) }
      it { expect(JSON.parse(response.body).keys).to match_array(%w[driver rate statistics]) }
    end

    context 'when all is ok' do
      before { get :index, params: { period: 'today' } }

      include_examples 'success response'
    end

    context 'when period is invalid' do
      before { get :index, params: { period: 'nottoday' } }

      include_examples 'success response'
    end
  end
end
