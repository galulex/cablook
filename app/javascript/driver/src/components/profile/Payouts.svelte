<script>
  import { createEventDispatcher } from 'svelte'
  import i18n from '../../../../pwa/i18n.js'
  import axios from 'axios'

  export let driverBalance

  const dispatch = createEventDispatcher()
  const MAX_AMOUNT = 5000
  const possiblePayoutAmount = driverBalance > MAX_AMOUNT ? MAX_AMOUNT : driverBalance

  let payoutErrorMessage = null
  let payoutDisabled = false
  let amount = parseInt(possiblePayoutAmount)

  const close = () => dispatch('close')

  const handleBackgroundClick = (event) => { if (event.target.classList.contains('modal')) close() }

  const payoutValue = (e) => {
    const val = parseInt(e.target.value);
    if (val > possiblePayoutAmount || val <= 0) {
      e.target.value = amount = possiblePayoutAmount
    } else if (val > driverBalance) {
      e.target.value = amount = driverBalance
    } else {
      amount = e.target.value
    }
  }

  const doPayout = () => {
    payoutDisabled = true
    axios.post('payouts', { amount: amount }).then(({ data }) => {
      dispatch('update', data.driver)
      payoutErrorMessage = null
      payoutDisabled = parseInt(data.driver.balance) <= 0
    }).catch(() => {
      payoutDisabled = false
      payoutErrorMessage = i18n.statistics.payout_error
    })
  }
</script>

<style>
 .modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 1.5rem;
  }

  .modal-content {
    background-color: var(--bg_gradient_color_1);
    color: var(--text_grey_color);
    padding: 20px;
    border-radius: 4px;
    text-align: center;
    box-shadow: 3px 3px 3px var(--shadow_color), inset -1px -1px 2px var(--shadow_color);
  }

  .centered-input {
    width: 100%;
    text-align: center;
  }

  .buttons button {
    margin: 10px;
    background: var(--bg_gradient_color_1);
    color: var(--text_grey_color);
  }

  .error {
    font-size: 1rem;
    color: var(--red_color);
  }
</style>

<div class='modal' on:click={handleBackgroundClick}>
  <div class='modal-content'>
    <h2>{i18n.statistics.payouts}</h2>
    <p>{i18n.statistics.balance}: {driverBalance}</p>
    <input class='centered-input' type='number' id='amount' on:input={payoutValue} value={possiblePayoutAmount} min='1' max={possiblePayoutAmount}/>
    {#if payoutErrorMessage}
      <p class='error'>{payoutErrorMessage}</p>
    {/if}
    <div class='buttons'>
      <button on:click={doPayout} disabled={payoutDisabled}>{i18n.statistics.do_payout}</button>
      <button on:click={close}>{i18n.statistics.cancel}</button>
    </div>
  </div>
</div>
