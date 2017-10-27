describe SearchEngine::FindCar do
  describe '.call' do
    context 'when nearest car is free car' do
      # TODO
      let!(:car_free) { Factory[:cars, status: Constants::Car::FREE] }
    end

    context 'when nearest car is busy car' do
    end

    context 'when nearest car not found' do
    end
  end
end
