let Bonus = {
  fetch: () => {
    ajax('bonus_trips', 'GET', {}, data => {
      console.log(data);
      if (data['bonus_trips'].length <= 0) {
        alert('foobar')
      } else {
        UI.addBonus()
      }
    })
  }
}
