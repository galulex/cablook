<script>
  export let speed
</script>

<style>
  .warning {
    position: absolute;
    z-index: 990;
    height: 100%;
    width: 100%;
    transition: opacity .3s, z-index .3s;
    background: red;
  }

  label {
    position: absolute;
    top: 50%;
    left: 50%;
    font-size: 3.5em;
    width: 100%;
    text-align: center;
    transform: translate(-50%, -50%);
    letter-spacing: 2px;
    background-color: var(--white_color);
    color: transparent;
    background-clip: text;
    -webkit-background-clip: text;
    -moz-background-clip: text;
    text-shadow: -2px -2px 3px var(--text_shadow_white_color), 2px 3px 3px var(--text_shadow_dark_color);
  }
</style>

<div class='warning'>
  <label>{speed} KM/h</label>
</div>
