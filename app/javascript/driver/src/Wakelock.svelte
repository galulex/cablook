<script>
  import { onMount, onDestroy} from 'svelte'

  let wakeLock
  
  onMount(() =>{
    requestWakeLock()
  })

  onDestroy(() =>{
    releaseWakeLock()
  })

  let requestWakeLock = async() => {
    try {
      if (!wakeLock && document.visibilityState === 'visible') {
        wakeLock = await navigator.wakeLock.request('screen')
        wakeLock.addEventListener('release', releaseWakeLock)
        document.addEventListener('visibilitychange', requestWakeLock)
      } 
    } catch (err) {
      console.log(`${err.name}, ${err.message}`)
    }
  }

  let releaseWakeLock = async() => {
    try {
      if (wakeLock) {
        await wakeLock.release()
        wakeLock = null
      }
    } catch (err) {
      console.log(`${err.name}, ${err.message}`)
    }
  }
</script>