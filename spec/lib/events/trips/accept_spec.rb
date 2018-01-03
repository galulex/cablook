describe Events::Trips::Accept do
  describe '.call' do
    let(:driver) { Factory[:driver, car_id: Factory[:car].id] }
    let(:trip) { Factory[:trip] }

    let(:data) { { trip_id: trip.id, driver_id: driver.id, car_id: driver.car_id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::ON_THE_WAY) }
    it { is_expected.to change { trip_repository.by_id(trip.id).car_id }.to(driver.car_id) }
    it { is_expected.to change { trip_repository.by_id(trip.id).driver_id}.to(driver.id) }
    it { is_expected.to change { car_repository.by_id(driver.car_id).status }.to(Constants::Car::WITH_NEXT_TRIP) }

    context 'when trip was accepted' do
      let(:trip) { Factory[:trip, status: Constants::Trip::ON_THE_WAY] }

      it { is_expected.not_to change { trip_repository.by_id(trip.id).status } }
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
