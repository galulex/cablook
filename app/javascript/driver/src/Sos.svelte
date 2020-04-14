<script>
  import { Link } from 'svelte-routing'

  import '../css/sos.css'

  export let sendSos
</script>

<button type='button' class='sos__button' on:click={sendSos}>SOS</button>
