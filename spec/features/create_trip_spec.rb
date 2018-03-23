RSpec.feature 'Trip', type: :feature, js: true do
  let(:phone_number)  { '630123456' }
  let(:start_address) { 'Active Bridge' }
  let(:address_1)     { 'Depot' }
  let(:address_2)     { 'McDonald\'s' }
  let(:end_address)   { 'Sport Life' }
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
    fill_in 'departure_address', with: start_address
    find('ul.form__location-list', text: start_address).first('li').click
    fill_in 'destination_address', with: address_1
    find('ul.form__location-list', text: address_1).first('li').click
    click_button 'done'
    click_button 'go'

    expect(alert.text).to include no_card
  end

  context 'user has a card' do
    before { Card.create(token: card.token, type: card.type, currency: card.currency, user_id: User.last.id) }

    scenario 'creat trip' do
      fill_in 'departure_address', with: start_address
      find('ul.form__location-list', text: start_address).first('li').click
      fill_in 'destination_address', with: address_1
      find('ul.form__location-list', text: address_1).first('li').click
      click_button 'add_point'
      all(:fillable_field, 'waypoints').last.set address_2
      find('ul.form__location-list', text: address_2).first('li').click
      click_button 'add_point'
      all(:fillable_field, 'waypoints').last.set end_address
      find('ul.form__location-list', text: end_address).first('li').click
      find('summary').click
      fill_in 'comment', with: comment
      page.execute_script('localStorage.ready = true')
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
