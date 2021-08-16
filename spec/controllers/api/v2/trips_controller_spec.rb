describe Api::V2::TripsController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { user.auth_token }

  before do
    request.headers['Auth-Token'] = auth_token
  end

  describe '#new' do
    subject { response }

    context 'when parameters come as a string' do
      it_behaves_like 'authorization_required'

      let(:params) { { trip: JSON.parse(File.read('spec/fixtures/build_params/as_string.json')) } }

      before { post :new, params: params }

      it { is_expected.to be_successful }

      context 'when params are invalid' do
        let(:params) { { trip: super().merge(destination: nil) } }

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end

    context 'when parameters come as an array' do
      it_behaves_like 'authorization_required'

      let(:params) { { trip: JSON.parse(File.read('spec/fixtures/build_params/as_array.json')) } }

      before { post :new, params: params }

      it { is_expected.to be_successful }

      context 'when params are invalid' do
        let(:params) { { trip: super().merge(destination: nil) } }

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end
  end
end
