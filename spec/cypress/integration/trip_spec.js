describe('Trip', () => {
  const userAttrs = {
    id: 1, email: 'user@example.info', phone_number: '+380633466667',
    auth_token: 'ZlLw', referral_code: 'HYFu3b'
  };
  const carAttrs = { id: 1 };
  const cardAttrs = { user_id: userAttrs.id };
  const driverAttrs = { id: 1, car_id: carAttrs.id, name: 'Super Driver' };
  beforeEach(() => {
    cy.app('clean')
    cy.appEval('Price.create')
    cy.appFactories([
      ['create', 'user', userAttrs], ['create', 'car', carAttrs], ['create', 'card', cardAttrs ],
      ['create', 'driver', driverAttrs]
    ]);
    cy.appEval("Redis.current.set('car_1', '49.4412378,32.0650127')")
    cy.stubGoogle()
    cy.visit('/')
  })

  it('orders a taxi', () => {
    localStorage.setItem('token', userAttrs.auth_token);
    localStorage.setItem('referral', userAttrs.referral_code);
    localStorage.setItem('email', userAttrs.email);
    localStorage.setItem('phone', userAttrs.phone_number);
    cy.visit('/');
    cy.get('.current-trip').within(($form) => {
      expect($form).to.contain('Search');
      cy.get('input:first')
        .should('have.attr', 'placeholder', 'From')
        .focus()
        .type('Active')
        .blur()
        .should('have.value', 'Active Bridge');
      cy.get('input').eq(1)
        .should('have.attr', 'placeholder', 'Where')
        .focus()
        .type('Nice')
        .blur()
        .should('have.value', 'Nice 2 Meet You');
      cy.get('input:last')
        .should('have.attr', 'type', 'submit')
        .should('have.value', 'OK').click();
    });
    cy.get('.confirm-container').within(($form) => {
      expect($form).to.contain('Confirm Trip')
      cy.get('.buttons').find('button.button.fixed')
        .should('have.text', 'GO')
        .click();
    })
    cy.get('.find_driver').within(($form) => {
      cy.get('button.button.fixed.cancel')
        .should('have.text', 'Cancel');
    })
    cy.appEval(`Events::Trips::Accept.(trip_id: 1, driver_id: ${driverAttrs.id}, car_id: ${carAttrs.id})`);
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name)
      expect($form).to.contain('Status - on the way')
      cy.get('button.button.cancel')
        .should('have.text', 'Cancel');
    })
    cy.appEval('Events::Trips::WaitingClient.(trip_id: 1)');
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name)
      expect($form).to.contain('Status - waiting client')
      cy.get('button.button.edit')
        .should('have.text', 'Edit');
    });
    cy.appEval('Events::Trips::Start.(trip_id: 1)');
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name)
      expect($form).to.contain('Status - driving')
      cy.get('button.button.edit')
        .should('have.text', 'Edit');
    });
    cy.appEval('Events::Trips::Finish.(trip_id: 1)');
    cy.get('.find_driver').within(($form) => {
      expect($form).to.contain('Rate trip')
      cy.get('textarea:first')
        .should('have.attr', 'placeholder', 'Comment')
        .focus()
        .type('Nice!')
        .blur()
        .should('have.value', 'Nice!');
      cy.get('button.button.fixed.warning')
        .should('have.text', 'OK')
        .click();
    })
    cy.get('.current-trip').within(($form) => {
      expect($form).to.contain('Search');
      cy.get('input:last')
        .should('have.attr', 'type', 'submit')
        .should('have.value', 'OK');
    })
  })

  it('updates', () => {
    localStorage.setItem('token', userAttrs.auth_token);
    localStorage.setItem('referral', userAttrs.referral_code);
    localStorage.setItem('email', userAttrs.email);
    localStorage.setItem('phone', userAttrs.phone_number);
    cy.visit('/');
    cy.get('.current-trip').within(($form) => {
      expect($form).to.contain('Search');
      cy.get('input:first')
        .should('have.attr', 'placeholder', 'From')
        .focus()
        .type('Active')
        .blur()
        .should('have.value', 'Active Bridge');
      cy.get('input').eq(1)
        .should('have.attr', 'placeholder', 'Where')
        .focus()
        .type('Nice')
        .blur()
        .should('have.value', 'Nice 2 Meet You');
      cy.get('input:last')
        .should('have.attr', 'type', 'submit')
        .should('have.value', 'OK').click();
    });
    cy.get('.confirm-container').within(($form) => {
      expect($form).to.contain('Confirm Trip')
      cy.get('.buttons').find('button.button.fixed')
        .should('have.text', 'GO')
        .click();
    })
    cy.get('.find_driver').within(($form) => {
      cy.get('button.button.fixed.cancel')
        .should('have.text', 'Cancel');
    })
    cy.appEval(`Events::Trips::Accept.(trip_id: 1, driver_id: ${driverAttrs.id}, car_id: ${carAttrs.id})`);
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name)
      expect($form).to.contain('Status - on the way')
      cy.get('button.button.cancel')
        .should('have.text', 'Cancel');
    })
    cy.appEval('Events::Trips::WaitingClient.(trip_id: 1)');
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name);
      expect($form).to.contain('56 uah');
      expect($form).to.contain('Status - waiting client');
      cy.get('button.button.edit')
        .should('have.text', 'Edit').click();
    });
    cy.get('.current-trip').within(($form) => {
      expect($form).to.contain('Search');
      cy.get('button.add-address')
        .should('have.text', 'Add address').click();
      cy.get('input.address').eq(2)
        .should('have.attr', 'placeholder', 'Where')
        .focus()
        .type('HELLO')
        .blur()
        .should('have.value', 'HELLO BURGER');
      cy.get('input:last')
        .should('have.attr', 'type', 'submit')
        .should('have.value', 'OK').click();
    });
    cy.get('.confirm-container').within(($form) => {
      expect($form).to.contain('Confirm Trip')
      cy.get('.buttons').find('button.button.fixed')
        .should('have.text', 'GO')
        .click();
    })
    cy.appEval('Events::Trips::Start.(trip_id: 1)');
    cy.get('.trips').within(($form) => {
      expect($form).to.contain(driverAttrs.name)
      expect($form).to.contain('Status - driving')
      cy.get('button.button.edit')
        .should('have.text', 'Edit');
    });
    cy.appEval('Events::Trips::Finish.(trip_id: 1)');
    cy.get('.find_driver').within(($form) => {
      expect($form).to.contain('Rate trip')
      cy.get('textarea:first')
        .should('have.attr', 'placeholder', 'Comment')
        .focus()
        .type('Nice!')
        .blur()
        .should('have.value', 'Nice!');
      cy.get('button.button.fixed.warning')
        .should('have.text', 'OK')
        .click();
    })
    cy.get('.current-trip').within(($form) => {
      expect($form).to.contain('Search');
      cy.get('input:last')
        .should('have.attr', 'type', 'submit')
        .should('have.value', 'OK');
    })
  })
})
