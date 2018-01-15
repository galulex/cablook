describe Api::SubscriptionsController, type: :controller do
  let(:subscription) { Factory[:subscription] }

  describe '#create' do
    subject { post :create, params: params }

    let(:params) { { subscription: subscription_params } }
    let(:subscription_params) { Factory.structs[:subscription].to_h.except(:id) }

    it { is_expected.to redirect_to('/?submit=true') }

    context 'when params are invalid' do
      let(:subscription_params) { Factory[:subscription].to_h.except(:id, :email) }

      it { is_expected.to redirect_to('/') }
    end
  end
end
