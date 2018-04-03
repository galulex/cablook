RSpec.feature 'Trip', type: :feature, js: true do
  let(:phone_number)  { '630123456' }
  let(:comment)       { 'Comment' }
  let(:car)           { Factory[:car] }
  let(:driver)        { Factory[:driver] }
  let!(:car_1)        { Car.create(number: car.number, status: 0, color: car.color, phone_number: car.phone_number) }
  let!(:driver_1)     { Driver.create(name: driver.name, username: driver.username, encrypted_password: driver.encrypted_password, auth_token: driver.auth_token, car_id: Car.last.id) }
  let(:wait)          { Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError }
  let(:alert)         { wait.until { page.driver.browser.switch_to.alert } }
  let(:no_card)       { 'На даний момент CabLook підтримує лише безготівковий спосіб оплати.' }
  let(:no_phone)      { 'phone_number не вірний формат' }
  let(:no_code)       { 'Код не вірний або час на верифікацію скінчився. Спробуйте ще раз.' }
  let(:card)          { Factory[:card] }
  let(:trip)          { Trip.last.update(car_id: Car.last.id, driver_id: Driver.last.id, status: 1, distance: 4000, start_at: Time.now, finish_at: Time.now + 1) }

  before { visit root_path }

  scenario 'user enter invalid phone number' do
    fill_in 'number', with: '0123456789'
    find('button').click

    expect(alert.text).to eq no_phone
  end

  scenario 'user enter invalid verification code' do
    fill_in 'number', with: phone_number
    find('button').click
    sleep(1)
    fill_in 'verification', with: '1111'
    click_button 'submit_code'

    expect(alert.text).to eq no_code
  end

  scenario 'user authorize' do
    fill_in 'number', with: phone_number
    find('button').click
    sleep(1)
    fill_in 'verification', with: User.last.verification_token
    click_button 'submit_code'

    expect(page).to have_content(I18n.t('order'))
  end

  scenario 'when user hasn\'t a card' do
    script_set_addresses
    script_add_addresses
    click_button 'done'
    click_button 'go'

    expect(alert.text).to include no_card
  end

  context 'user has a card' do
    before { Card.create(token: card.token, type: card.type, currency: card.currency, user_id: User.last.id) }

    scenario 'create trip' do
      script_set_addresses
      script_add_addresses
      click_button 'add_point'
      script_add_waypoints
      find('summary').click
      fill_in 'comment', with: comment
      script_set_localstorage
      click_button 'done'
      click_button 'go'
      sleep(1)
      trip
      expect(page).to have_content(I18n.t('shared.user_form.looking_for_driver'))
      visit root_path

      expect(page).to have_content(I18n.t('structs.trip.cost'))
    end
  end
end

def script_set_addresses
  page.execute_script(" document.getElementById('departure_address').value = 'Active Bridge' ")
  page.execute_script(" document.getElementById('destination_address').value = 'Mcdonalds' ")
  page.execute_script(" document.getElementById('departure_address').dataset.place = 'ChIJIar5649L0UARx2zALYRK6OE' ")
  page.execute_script(" document.getElementById('destination_address').dataset.place = 'ChIJiy_YjWlM0UARJFq73yvu1h0' ")
end

def script_add_addresses
  page.execute_script(" trip.departure_address = 'Active Bridge, Marshala Krasovskoho Street, Cherkasy, Cherkaska oblast, Ukraine' ")
  page.execute_script(" trip.destination_address = 'Sport Life, Yaroslavska Street, Cherkasy, Cherkaska oblast, Ukraine' ")
  page.execute_script(" trip.dearture = [ 49.4267725, 32.05338589999997 ] " )
  page.execute_script(" trip.destination = [ 49.43505769999999, 32.01106010000001 ] " )
end

def script_add_waypoints
  page.execute_script(" document.getElementsByClassName('form__location-field')[2].value = 'Sport Life' ")
  page.execute_script(" document.getElementsByClassName('form__location-field')[2].dataset.place = 'ChIJ0xjbtn5L0UARTQBvFZE58-I' ")
  page.execute_script(" trip.waypoints = [ '49.4409414, 32.06395700000007' ] " )
end

def script_set_localstorage
  page.execute_script('localStorage.ready = true')
end
