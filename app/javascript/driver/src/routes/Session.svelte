<script>
  import axios from 'axios';

  import '../../css/login_page.css'

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
    let params = formData(e.target)
    axios.patch('assign_car', { driver: params }).then((res) => {
      disabled = false
      let car = cars.find((car) => { return car.id.toString() === params.car_id })
      login(res.data.driver, car)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }
</script>

<div class='login-page'>
  <div class='login-form'>
    <h1>Log In</h1>
    {#if cars.length < 1}
      <form action='#' on:submit={create}>
        <input name='username' type='text' placeholder='Username' required/>
        <br/>
        <input name='password' type='password' placeholder='Password' required/>
        <br/>
        <button disabled={disabled} type='submit'>OK</button>
      </form>
    {:else}
      <form action='#' on:submit={update} class='select-car'>
        <select name='car_id' required>
          <option value='' selected disabled>Select the car</option>
          {#each cars as car, i}
            <option value={car.id}>{car.number}</option>
          {/each}
        </select>
        <br/>
        <button disabled={disabled} type='submit'>OK</button>
      </form>
    {/if}
  </div>
</div>
