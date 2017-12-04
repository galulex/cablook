describe CardCallbacksController, type: :controller do
  describe '#create' do
    subject { response }

    let(:params) { JSON.parse(File.read('spec/fixtures/card_callback.json')) }
    let!(:user) { Factory[:user, phone_number: "+#{params['phone']}"] }

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }

    context 'when something went wrong' do
      let(:params) { super().merge(recToken: nil) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
