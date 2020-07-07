<script>
  import axios from 'axios';

  export let login

  let disabled = false
  let cars = []
  let token

  let formData = (form) => {
    return Object.fromEntries(new FormData(form))
  }

  let create = (e) => {
    e.preventDefault()
    disabled = true
    axios.post('sessions', { driver: formData(e.target) }).then((res) => {
      disabled = false
      token = res.data.auth_token
      cars = res.data.cars
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }

  let update = (e) => {
    e.preventDefault()
    let params = formData(e.target)
    axios.patch('assign_car', { driver: params }, { headers: { 'Auth-Token': token }}).then((res) => {
      disabled = false
      let car = cars.find((car) => { return car.id.toString() === params.car_id })
      login(res.data.driver, car)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }
</script>

<style>
  main {
    height: 100vh;
    background: linear-gradient(to right, var(--bg_gradient_color_2), var(--bg_gradient_color_1), var(--bg_gradient_color_2));
  }

  h3 {
    font-weight: 100;
    margin-top: 0px;
  }

  button {
    background: linear-gradient(to right, var(--bg_gradient_color_2), var(--bg_gradient_color_1), var(--bg_gradient_color_2));
    padding: 16px;
    margin: 10px 0;
    width: 100%;
    color: var(--main_green_color);
    font-size: 14px;
    font-weight: 600;
  }

  input, select {
    width: 100%;
    font-size: 14px;
    padding: 16px;
    margin: 10px 0;
  }

  .login-form {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
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

<main>
  <div class='login-form'>
    <h3>Log In</h3>
    {#if cars.length < 1}
      <form action='#' on:submit={create}>
        <input name='username' type='text' placeholder='Username' required/>
        <input name='password' type='password' placeholder='Password' required/>
        <button disabled={disabled} type='submit'>OK</button>
      </form>
    {:else}
      <form action='#' on:submit={update} class='select-car'>
        <select name='car_id' size=5 required>
          <option value='' selected disabled>Select the car</option>
          {#each cars as car, i}
            <option value={car.id}>{car.number}</option>
          {/each}
        </select>
        <button disabled={disabled} type='submit'>OK</button>
      </form>
    {/if}
  </div>
</main>
