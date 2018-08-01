let Bonus = {
  fetch: () => {
    ajax('bonus_trips', 'GET', {}, data => {
      let bonus_data = data['bonus_trips']
      for (var i = 0; i < bonus_data.length; i++) {
        let x = bonus_data[i].status
        if (x == 1) {
          UI.addBonus()
        }
      }
    })
  }
}
