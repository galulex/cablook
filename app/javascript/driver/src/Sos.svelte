<script>
  import { Link } from 'svelte-routing'

  export let sendSos
</script>

<style>
.sos__button {
  position: absolute;
  left: 10px;
  bottom: calc(10vh + 10px);
  padding: 15px 0;
  width: 20%;
  max-width: 95px;
  min-width: 50px;
  background: red;
  border: none;
  color: white;
  font-size: 1.2em;
  font-weight: 400;
  cursor: pointer;
  box-shadow: 4px 3px 12px var(--shadow_color), inset 2px 2px 3px var(--nav_shadow_white_color), inset -2px -2px 3px var(--shadow_color);
}

@media only screen and (min-width: 720px) and (max-width: 1024px) {
  .sos__button {
    bottom: calc(9vh + 10px);
    left: 15px;
  }
}

@media only screen and (max-width: 768px) {
  .sos__button {
    padding: 10px 0;
  }
}
</style>

<button type='button' class='sos__button' on:click={sendSos}>SOS</button>
