<script>
  import CancelSound from '../public/sounds/cancel.mp3'
  import AcceptSound from '../public/sounds/accept.mp3'
  import ProposalSound from '../public/sounds/proposal.mp3'
  import DecidedSound from '../public/sounds/decided.mp3'
  import UpdateSound from '../public/sounds/update.mp3'

  const sounds = {
    cancel: new Audio(CancelSound),
    accept: new Audio(AcceptSound),
    proposal: new Audio(ProposalSound),
    decline: new Audio(DecidedSound),
    update: new Audio(UpdateSound),
  }

  const vibrations = {
    cancel: [1000],
    accept: [200, 100, 200],
    proposal: [200, 100, 200],
    decline: [1000],
    update: [200, 100, 200],
  }

  let klass

  window.play = (type) => {
    try {
      sounds[type].play()
      navigator.vibrate(vibrations[type])
    } catch(e) {
    }
  }

  let click = (e) => {
    klass = 'hidden'
    window.play('update')
  }
</script>

<style>
  button {
    position: absolute;
    z-index: 10000;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    font-size: 3rem;
    color: #efcc3a;
    border: none;
    width: 100%;
    transition: opacity .3s, z-index .3s;
  }

  .hidden {
    opacity: 0;
    z-index: -1;
  }
</style>

<button type='button' class={klass} on:click={click}>START</button>
