describe AuthorizationsController, type: :controller do
  describe '#create' do
    subject { response }

    let!(:user) { Factory[:user] }
    let(:params) { { user: { phone_number: user.phone_number, password: '12341234' } } }

    before { post :create, params: params }

    it { is_expected.to have_http_status(:success) }

    context 'when phone_number is blank' do
      let(:params) { { user: { phone_number: '', password: Faker::Internet.password } } }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
