<script>
  import axios from 'axios'
  export let trip
  export let updateTrip
  export let disabled
  let unrelease = () => {
    if (!confirm('Викинути замовлення в ефір?')) return
    disabled = true
    axios.patch(`trips/${trip.id}/unrelease`).then(res => {
      updateTrip(res.data)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }
</script>

<button on:click={unrelease} disabled={disabled}><i>↩</i></button>
