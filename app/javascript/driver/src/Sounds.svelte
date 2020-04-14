<script>
  import CancelSound from '../public/sounds/cancel.mp3'
  import AcceptSound from '../public/sounds/accept.mp3'
  import ProposalSound from '../public/sounds/proposal.mp3'
  import DecidedSound from '../public/sounds/decided.mp3'
  import UpdateSound from '../public/sounds/update.mp3'
  import SosSound from '../public/sounds/sos.mp3'

  const sounds = {
    cancel: new Audio(CancelSound),
    accept: new Audio(AcceptSound),
    proposal: new Audio(ProposalSound),
    decline: new Audio(DecidedSound),
    update: new Audio(UpdateSound),
    sos: new Audio(SosSound)
  }

  const vibrations = {
    cancel: [1000],
    accept: [200, 100, 200],
    proposal: [200, 100, 200],
    decline: [1000],
    update: [200, 100, 200],
    sos: [100,30,100,30,100,200,200,30,200,30,200,200,100,30,100,30,100]
  }

  let klass = 'start-page'

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
  .start-page {
    position: absolute;
    z-index: 10000;
    height: 100%;
    width: 100%;
    transition: opacity .3s, z-index .3s;
    background: linear-gradient(to bottom, var(--main_green_color), var(--main_dark_color));
  }

  label {
    position: absolute;
    top: 50%;
    left: 50%;
    font-size: 3.5em;
    width: 100%;
    text-align: center;
    transform: translate(-50%, -50%);
    letter-spacing: 2px;
    background-color: var(--white_color);
    color: transparent;
    opacity: 0.1;
    background-clip: text;
    -webkit-background-clip: text;
    -moz-background-clip: text;
    text-shadow: -2px -2px 3px var(--text_shadow_white_color), 2px 3px 3px var(--text_shadow_dark_color);
  }

  label:hover {
    text-shadow: -1px -1px 1px var(--text_shadow_white_color), 1px 1px 1px var(--text_shadow_dark_color);
    cursor: pointer;
  }

  label:active {
    text-shadow: 2px 2px 2px var(--text_shadow_white_color), 0px 0px 2px var(--text_shadow_dark_color);
    background-color: var(--text_shadow_dark_color);
  }

  .hidden {
    display: none;
    opacity: 0;
    z-index: -1;
  }
</style>

<div on:click={click} class={klass}>
  <label> START </label>
</div>
