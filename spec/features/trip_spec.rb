RSpec.feature 'Trip', type: :feature, js: true do
  let!(:user) { create(:user) }
  let!(:work) { FavoriteAddress.create(user: user, name: 'Work', location: '49.426269,32.05418899999995', address: 'Active Bridge') }
  let!(:home) { FavoriteAddress.create(user: user, name: 'Home', location: '49.44546829999999,32.071774000000005', address: 'Haharina, 55') }
  let!(:card) { create(:card, user: user) }
  let!(:car) { create(:car) }
  let!(:driver) { create(:driver, car: car) }
  let!(:price) { Price.delete_all && Price.create }

  before do
    Redis.current.set("car_#{car.id}", '49.4412378,32.0650127')
    Capybara.default_host = 'http://app.lvh.me'
    visit('http://app.lvh.me:9887')
    Capybara.evaluate_script "localStorage.setItem('token', '#{user.auth_token}');"
    Capybara.evaluate_script "localStorage.setItem('referral', '#{user.referral_code}');"
    Capybara.evaluate_script "localStorage.setItem('email', '#{user.email}');"
    Capybara.evaluate_script "localStorage.setItem('phone', '#{user.phone_number}');"
    visit('http://app.lvh.me:9887')
  end

  it 'orders taxi' do
    wait 3 do
      has_text? 'GO'
    end
    all('input')[1].trigger(:focus)
    all('input')[1].set('')
    wait 3 do
      first('li.prediction', visible: false).trigger(:click)
    end
    all('input')[2].trigger(:focus)
    all('input')[2].set('')
    all('li.prediction', visible: false)[1].trigger(:click)
    wait 3 do
      find_button('GO 56').trigger(:click)
    end
    wait 3 do
      has_text? 'Cancel'
    end
    Events::Trips::Accept.(trip_id: trip.id, driver_id: driver.id, car_id: car.id)
    wait 3 do
      has_no_text? 'Edit'
    end
    Events::Trips::WaitingClient.(trip_id: trip.id)
    wait 3 do
      has_text? 'Edit'
    end
    expect(page).to have_content('56')
    Events::Trips::Start.(trip_id: trip.id)
    wait 3 do
      has_text? 'Edit'
    end
    find_button('Edit').trigger(:click)
    find('button.add-address').trigger(:click)
    all('input')[3].trigger(:focus)
    all('input')[3].set('')
    first('li.prediction', visible: false).trigger(:click)
    wait 3 do
      find_button('GO 56').trigger(:click)
    end
    wait 3 do
      has_text? 'Edit'
    end
    expect(page).to have_content(trip.cost)
    Events::Trips::Finish.(trip_id: trip.id)
    wait 3 do
      has_text? 'Rate trip'
    end
    first('textarea').set('Nice!')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'GO'
    end
  end

  def trip
    @trip ||= Trip.last
  end

end
