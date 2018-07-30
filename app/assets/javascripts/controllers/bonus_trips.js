let Bonus = {
  fetch: () => {
    ajax('bonus_trips', 'GET', {}, data => {
      if (data['bonus_trips'].length > 0) {
        UI.addBonus()
      }
    })
  }
}
