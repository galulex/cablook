describe Api::UsersController, type: :controller do
  let(:user) { create(:user) }

  describe '#show' do
    subject { response }

    context 'when token is invalid' do
      before { get :show, as: :json }

      it { is_expected.to have_http_status(404) }
    end

    context 'when token is valid' do
      before { request.headers['Auth-Token'] = user.auth_token }
      before { get :show, as: :json }

      it { is_expected.to have_http_status(200) }
      it 'has http response headers' do
        expect(response.headers['Cache-Control']).to match /no-cache, no-store/
        expect(response.headers['Pragma']).to match /no-cache/
        expect(response.headers['Expires']).to eq "0"
      end
    end
  end

  describe '#update' do
    let(:params) { { user: { locale: 'en' } } }

    subject { response }

    context 'when token is invalid' do
      before { patch :update, params: params }

      it { is_expected.to have_http_status(404) }
    end

    context 'when token is valid' do
      before { request.headers['Auth-Token'] = user.auth_token }

      context 'and locale is valid' do
        before { patch :update, params: params }

        it { is_expected.to have_http_status(200) }
      end

      context 'and locale is invalid' do
        let(:params) { { user: { locale: 'invalid' } } }
        before { patch :update, params: params }

        it { is_expected.to have_http_status(422) }
      end
    end
  end
end
