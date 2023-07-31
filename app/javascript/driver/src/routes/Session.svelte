<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'

  export let login

  let disabled = false

  onMount(() => {
    document.body.style.background = '#ced5d3'
  })

  onDestroy(() => {
    document.body.style.background = '#19a160'
  })

  let formData = (form) => {
    return Object.fromEntries(new FormData(form))
  }

  let create = (e) => {
    disabled = true
    axios.post('sessions', { driver: formData(e.target) }).then((res) => {
      disabled = false
      login(res.data, res.data.car)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }
</script>

<style>
  main {
    height: 100vh;
    background: linear-gradient(0deg, var(--bg_gradient_color_1), var(--bg_gradient_color_2));
  }

  h3 {
    font-weight: 100;
    margin-top: 0px;
  }

  button {
    background: linear-gradient(0deg, var(--bg_gradient_color_2), var(--bg_gradient_color_1), 40%);
    padding: 16px;
    margin: 10px 0;
    width: 100%;
    color: var(--main_green_color);
    font-size: 14px;
    font-weight: 600;
  }

  input {
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
      <form action='#' on:submit|preventDefault={create}>
        <input name='username' type='text' placeholder='Username' autocomplete="username" required/>
        <input name='password' type='password' placeholder='Password' autocomplete="password" required/>
        <button disabled={disabled} type='submit'>OK</button>
      </form>
  </div>
</main>
