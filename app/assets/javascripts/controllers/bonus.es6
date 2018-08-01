let Bonus = {
  fetch: () => {
    ajax('bonus_trips', 'GET', {}, data => {
      if (data['bonus_trips'].some((e) => { return e.status == 1 })) UI.addBonus()
    })
  }
}
