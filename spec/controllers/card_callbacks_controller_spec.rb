describe CardCallbacksController, type: :controller do
  describe '#create' do
    subject { response }

    let(:params) { JSON.parse(File.read('spec/fixtures/card_callback.json')) }

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }
  end
end
