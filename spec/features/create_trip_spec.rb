RSpec.feature 'Trip', type: :feature, js: true do
  let!(:user) { create(:user) }
  let!(:card) { create(:card, user: user) }
  let!(:car) { create(:car) }
  let!(:driver) { create(:driver, car: car) }
  let!(:price) { Price.create }

  before do
    Capybara.default_host = 'http://app.example.com'
    visit('/')
  end

  it 'orders a taxi' do
    find('input#number').set(user.phone_number.slice(4..-1))
    click_button 'Sign in'
    find('input#code').set(User.last.verification_token)
    click_button 'Next'
    sleep 1
    first('input').set('Active Bridge')
    first('input').trigger(:focus)
    sleep 1
    all('input')[1].set('Nice 2 Meet You')
    all('input')[1].trigger(:focus)
    sleep 1
    click_button 'OK'
    sleep 1
    expect(page).to have_content('Confirm Trip')
    click_button 'GO'
    sleep 1
    expect(page).to have_content('Cancel')
    Events::Trips::Accept.(trip_id: trip.id, driver_id: driver.id, car_id: car.id)
    sleep 1
    expect(page).to have_content(driver.name)
    Events::Trips::Finish.(trip_id: trip.id)
    sleep 1
    expect(page).to have_content('Rate trip')
    first('textarea').set('Nice!')
    click_button 'OK'
    sleep 1
    expect(page).to have_content('Search')
  end

  def trip
    @trip ||= Trip.last
  end
end
