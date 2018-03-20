RSpec.feature 'Create trip', type: :feature, js: true do
  let(:phone_number)  { 630123456 }
  let(:card) { Factory[:card] }
  let(:start_address) { 'Active Bridge' }
  let(:end_address) { 'Sport Life' }
  let(:comment) { 'Comment' }

  let!(:car) { Factory[:car] }
  let!(:driver) { Factory[:driver] }

  before do
    Car.create(number: car.number, status: 0, color: car.color, phone_number: car.phone_number)
    Driver.create(name: driver.name, username: driver.username, encrypted_password: driver.encrypted_password, auth_token: driver.auth_token, car_id: Car.last.id )
  end

  it 'when user authorize' do
    visit root_path

    fill_in 'number', with: phone_number
    find('button').click
    sleep 1
    fill_in 'verification', with: User.last.verification_token
    click_button 'submit_code'

    expect(page).to have_content('Замовити')
  end

  context 'when the user has a card' do
    before { Card.create(token: card.token, type: card.type, currency: card.currency, user_id: User.last.id) }

    it 'created trip success' do
      visit root_path

      fill_in 'departure_address', with: start_address
      find('ul.form__location-list', text: start_address).first('li').click
      sleep 0.4

      fill_in 'destination_address', with: end_address
      find('ul.form__location-list', text: end_address).first('li').click
      sleep 0.4

      find('summary').click
      fill_in 'comment', with: comment
      page.execute_script("localStorage.ready = true")

      click_button 'done'
      sleep 0.4

      click_button 'go'
      sleep 0.4

      Trip.last.update(car_id: Car.last.id, driver_id: Driver.last.id, status: 1, distance: 4000, start_at: Time.now, finish_at: Time.now + 1)
      sleep 0.2

      expect(page).to have_content('Одну хвилинку, підбираємо машинку')
      sleep 1

      visit root_path
      sleep 1

      expect(page).to have_content('Вартість')
    end
  end
end
