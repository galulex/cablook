describe Events::Cards::New do
  describe '.call' do
    subject { -> { described_class.call(current_user: current_user, api_card_callback_url: api_card_callback_url) } }

    let(:current_user) { create(:user) }
    let(:api_card_callback_url) { 'callback_url' }

    context 'when Wayforpay' do
      let(:wfp_params) { { data: 'data' } }
      let(:wfp_double) { double(Wfp, params: wfp_params, sign: 'SimpleSignature') }

      before do
        allow(Wayforpay).to receive(:encrypt_secret_key).and_return('key')
        allow(Wfp).to receive(:new).with(current_user, api_card_callback_url).and_return(wfp_double)

        subject.call
      end

      it { expect(Wfp).to have_received(:new).with(current_user, api_card_callback_url) }
      it { expect(subject.call).to eq({ method: :wayforpay, payload: wfp_params }) }
    end

    context 'when Fondy' do
      let(:fondy_response) { JSON.parse(File.read('spec/fixtures/fondy/card_verify_success_response.json')) }
      let(:fondy_checkout_url) { fondy_response['response']['checkout_url'] }

      before { Settings.update!(payment_system: :fondy) }

      it { expect(subject.call).to eq({method: :fondy, payload: fondy_checkout_url }) }
    end
  end
end