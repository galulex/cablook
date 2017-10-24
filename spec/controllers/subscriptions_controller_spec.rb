describe SubscriptionsController, type: :controller do
  let(:subscription) { Factory[:subscription] }

  describe '#create' do
    subject { response }

    let(:params) { { subscription: subscription_params } }
    let(:subscription_params) { Factory.structs[:subscription].to_h.except(:id) }

    before { post :create, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }

    context 'when params are invalid' do
      let(:subscription_params) { Factory[:subscription].to_h.except(:id, :email) }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
