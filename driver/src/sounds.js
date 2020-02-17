const sounds = {
  cancel: new Audio('sounds/cancel.mp3'),
  accept: new Audio('sounds/accept.mp3'),
  proposal: new Audio('sounds/proposal.mp3'),
  decline: new Audio('sounds/cancel.mp3'),
  update: new Audio('sounds/update.mp3'),
}

// const vibrations = {
//   cancel: [300, 100, 300],
//   accept: [200, 100, 200],
//   proposal: [200, 100, 200],
//   decline: [1000],
//   update: [200, 100, 200],
// }

// const vibrate = action => {
//   if (navigator.vibrate) navigator.vibrate(vibrations[action])
// }

export default sounds
