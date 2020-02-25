<script>
  const sounds = {
    cancel: new Audio('sounds/cancel.mp3'),
    accept: new Audio('sounds/accept.mp3'),
    proposal: new Audio('sounds/proposal.mp3'),
    decline: new Audio('sounds/cancel.mp3'),
    update: new Audio('sounds/update.mp3'),
  }

  const vibrations = {
    cancel: [1000],
    accept: [200, 100, 200],
    proposal: [200, 100, 200],
    decline: [1000],
    update: [200, 100, 200],
  }

  let btn

  window.play = (type) => {
    btn.onclick = () => {
      sounds[type].play()
      if (navigator.vibrate) navigator.vibrate(vibrations[type])
    }
    btn.click()
  }

</script>

<style>
  button {
    position: absolute;
    z-index: -1;
    opacity: 0;
  }
</style>

<button type='button' bind:this={btn}/>
