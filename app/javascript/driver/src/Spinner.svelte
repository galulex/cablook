<style>
  h3 {
    font-weight: 100;
    margin-top: 0px;
    text-align: center;
    padding-top: 30vh;
  }

  .outer-circle {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    height: 100px;
    width: 100px;
    box-shadow: inset 5px 3px 5px var(--shadow_color);
  }

  .inner-circle {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    height: 70px;
    width: 70px;
    box-shadow: 5px 3px 5px var(--shadow_color);
  }

  .spinner {
    height: 100px;
    width: 100px;
    border-radius: 50%;
    border: 15px solid transparent;
    border-top-color: var(--main_green_color);
    animation: spinner 1000ms linear infinite;
    position: relative;
    right: 15px;
    top: -15px;
  }
  .spinner:before, .spinner:after {
    content: '';
    width: 15px;
    height: 15px;
    border-radius: 50%;
    background: var(--main_green_color);
    position: absolute;
    top: -2px;
  }

  .spinner:before {
    left: -3px;
  }

  .spinner:after {
    right: -3px;
  }

  @keyframes spinner {
    to {
      transform: rotate(360deg);
    }
  }
</style>

<h3>Завантаження</h3>
<div class="outer-circle">
  <div class="inner-circle">
    <div class="spinner"></div>
  </div>
</div>
