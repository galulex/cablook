RSpec.feature 'Trip', type: :feature, js: true do
  let(:phone_number)  { 630123456 }
  let(:start_address) { 'Active Bridge' }
  let(:end_address) { 'Sport Life' }
  let(:comment) { 'Comment' }
  let(:car) { Factory[:car] }
  let(:driver) { Factory[:driver] }
  let!(:car_1) { Car.create(number: car.number, status: 0, color: car.color, phone_number: car.phone_number) }
  let!(:driver_1) { Driver.create(name: driver.name, username: driver.username, encrypted_password: driver.encrypted_password, auth_token: driver.auth_token, car_id: Car.last.id ) }

  scenario 'user authorize' do
    visit root_path
    fill_in 'number', with: phone_number
    find('button').click; sleep 1
    fill_in 'verification', with: User.last.verification_token
    click_button 'submit_code'

    expect(page).to have_content(I18n.t('order'))
  end

  context 'user has a card' do
    let(:card) { Factory[:card] }
    let(:trip) { Trip.last.update(car_id: Car.last.id, driver_id: Driver.last.id, status: 1, distance: 4000, start_at: Time.now, finish_at: Time.now + 1) }
    before { Card.create(token: card.token, type: card.type, currency: card.currency, user_id: User.last.id) }

    scenario 'creat trip' do
      visit root_path
      fill_in 'departure_address', with: start_address
      find('ul.form__location-list', text: start_address).first('li').click
      sleep 0.5
      fill_in 'destination_address', with: end_address
      find('ul.form__location-list', text: end_address).first('li').click
      sleep 0.5
      find('summary').click
      fill_in 'comment', with: comment
      page.execute_script("localStorage.ready = true")
      sleep 0.2
      click_button 'done'
      sleep 1
      click_button 'go'
      sleep 1
      trip
      expect(page).to have_content(I18n.t('shared.user_form.looking_for_driver'))
      visit root_path

      expect(page).to have_content(I18n.t('structs.trip.cost'))
    end
  end
end
