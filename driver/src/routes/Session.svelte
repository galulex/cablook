<script>
  import axios from 'axios';

  export let login

  let disabled = false
  let cars = []

  let formData = (form) => {
    return Object.fromEntries(new FormData(form))
  }

  let create = (e) => {
    e.preventDefault()
    disabled = true
    axios.post('sessions', { driver: formData(e.target) }).then((res) => {
      disabled = false
      axios.defaults.headers.common['Auth-Token'] = res.data.auth_token
      cars = res.data.cars
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }

  let update = (e) => {
    e.preventDefault()
    axios.patch('assign_car', { driver: formData(e.target) }).then((res) => {
      disabled = false
      login(res.data.driver)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }
</script>

<h1>Log In</h1>
{#if cars.length < 1}
  <form action='#' on:submit={create}>
    <input name='username' type='text' required/>
    <br/>
    <input name='password' type='password' required/>
    <br/>
    <button disabled={disabled} type='submit'>OK</button>
  </form>
{:else}
  <form action='#' on:submit={update}>
    <select name='car_id' required>
      <option value='' selected disabled>Select Car</option>
      {#each cars as car, i}
        <option value={car.id}>{car.number}</option>
      {/each}
    </select>
    <br/>
    <button disabled={disabled} type='submit'>OK</button>
  </form>
{/if}
