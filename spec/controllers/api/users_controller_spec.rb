describe Api::UsersController, type: :controller do
  let(:user) { create(:user) }
  
  describe "#show" do
    subject { response }
    
    context "when token is invalid" do
      before { get :show, as: :json }
    it { is_expected.to have_http_status(404) }
    end

    context "when token is valid " do
      before { request.headers['Auth-Token'] = user.auth_token }
      before { get :show, as: :json }
    it { is_expected.to have_http_status(200) }
    end
  end
end
