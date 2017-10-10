shared_examples_for 'authorization_required' do
  context 'when an auth_token is not found' do
    let(:auth_token) { 'invalid_token' }

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context 'when there is no an auth_token' do
    let(:auth_token) { '' }

    it { is_expected.to have_http_status(:unauthorized) }
  end
end
