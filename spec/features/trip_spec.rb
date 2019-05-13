RSpec.feature 'Trip', type: :feature, js: true do
  let!(:user) { create(:user) }
  let!(:card) { create(:card, user: user) }
  let!(:car) { create(:car) }
  let!(:driver) { create(:driver, car: car) }
  let!(:price) { Price.delete_all && Price.create }

  before do
    Redis.current.set("car_#{car.id}", '49.4412378,32.0650127')
    Capybara.default_host = 'http://app.lvh.me'
    visit('http://app.lvh.me:9887')
  end

  it 'orders a taxi' do
    find('input#number').set(user.phone_number.slice(4..-1))
    find_button('Sign in').trigger(:click)
    wait 3 do
      has_text? 'Next'
    end
    find('input#code').set(User.last.verification_token)
    find_button('Next').trigger(:click)
    wait 3 do
      has_text? 'Search'
    end
    first('input').set('Active')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Active Bridge'
    end
    first('li.prediction').trigger(:click)
    all('input')[1].set('Nice')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Nice 2 Meet You'
    end
    first('li.prediction').trigger(:click)
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Confirm Trip'
    end
    click_button 'GO'
    wait 3 do
      has_text? 'Cancel'
    end
    Events::Trips::Accept.(trip_id: trip.id, driver_id: driver.id, car_id: car.id)
    wait 3 do
      has_text? driver.name
      has_no_text? 'Edit'
    end
    Events::Trips::WaitingClient.(trip_id: trip.id)
    wait 3 do
      has_text? driver.name
      has_text? 'Edit'
    end
    Events::Trips::Start.(trip_id: trip.id)
    wait 3 do
      has_text? driver.name
      has_text? 'Edit'
    end
    expect(page).to have_selector("button[class='button edit']")
    expect(page).to have_content(driver.name)
    Events::Trips::Finish.(trip_id: trip.id)
    wait 3 do
      has_text? 'Rate trip'
    end
    first('textarea').set('Nice!')
    click_button 'OK'
    wait 3 do
      has_text? 'Search'
    end
  end

  it 'updates' do
    find('input#number').set(user.phone_number.slice(4..-1))
    find_button('Sign in').trigger(:click)
    wait 3 do
      has_text? 'Next'
    end
    find('input#code').set(User.last.verification_token)
    find_button('Next').trigger(:click)
    wait 3 do
      has_text? 'Search'
    end
    first('input').set('Active')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Active Bridge'
    end
    first('li.prediction').trigger(:click)
    all('input')[1].set('Nice')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Nice 2 Meet You'
    end
    first('li.prediction').trigger(:click)
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Confirm Trip'
    end
    click_button 'GO'
    wait 3 do
      has_text? 'Cancel'
    end
    Events::Trips::Accept.(trip_id: trip.id, driver_id: driver.id, car_id: car.id)
    wait 3 do
      has_text? driver.name
      has_no_text? 'Edit'
    end
    Events::Trips::WaitingClient.(trip_id: trip.id)
    wait 3 do
      has_text? driver.name
      has_text? 'Edit'
    end
    expect(page).to have_content('56 uah')
    find('button#edit_trip').trigger(:click)
    find('button.add-address').trigger(:click)
    all('input')[2].set('HELLO')
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'HELLO BURGER'
    end
    first('li.prediction').trigger(:click)
    find_button('OK').trigger(:click)
    wait 3 do
      has_text? 'Confirm Trip'
    end
    click_button 'GO'
    wait 3 do
      has_text? 'Edit'
    end
    expect(page).to have_content('Active Bridge')
    expect(page).to have_content('Nice 2 Meet You')
    expect(page).to have_content('HELLO BURGER')
    expect(page).to have_content(trip.cost)
    Events::Trips::Finish.(trip_id: trip.id)
    wait 3 do
      has_text? 'Rate trip'
    end
    first('textarea').set('Nice!')
    click_button 'OK'
    wait 3 do
      has_text? 'Search'
    end
  end

  def trip
    @trip ||= Trip.last
  end
end
