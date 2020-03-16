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
</div>

<style>

.login-form {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.login-form h1 {
  margin-top: 0px;
}

.login-form input, .login-form select {
  width: 100%;
  padding: 12px 20px;
  border: none;
  border-bottom: 2px solid #312d50;
  background: transparent;
}

.login-form input:focus, .login-form select:focus {
  outline: none;
}

.login-form button {
  padding: 6px 10px;
  margin: 10px 0;
  width: 100%;
  border: none;
  color: white;
  background: #19a160;
  cursor: pointer;
}

.login-form input:-webkit-autofill,
.login-form input:-webkit-autofill:hover,
.login-form input:-webkit-autofill:focus {
  transition: background-color 5000s ease-in-out 0s;
}

@media only screen and (min-width : 720px) {
  .login-form {
    width: 50vh;
  }
}

@media only screen and (min-width : 320px) and (max-width : 720px) {
  .login-form {
    width: 70%;
  }
}

</style>
