describe DriversController, type: :controller do
  let(:user) { Factory[:user] }

  describe '#assign_car' do
    subject { response }

    let(:params) { { car_id: car.id, name: 'name', auth_token: user.auth_token } }
    let(:driver_params) { Factory.structs[:driver].to_h.except(:id) }
    let(:car) { Factory[:car] }

    before { patch :assign_car, params: params, as: :json }

    it { is_expected.to have_http_status(:success) }
  end
end
