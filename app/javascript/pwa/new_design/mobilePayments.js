import { h } from 'preact'
import { useEffect } from 'preact/hooks'
import SearchLogo from '../images/search_logo.svg'

export default function MobilePayments({ cost, createTrip, setButtonDisabled, buttonDisabled }) {

  const mobilePaymentScript = () => {
    const loadScript = (src, onLoad) => {
      const script = document.createElement('script')
      script.src = src
      script.async = true
      script.onload = onLoad
      document.head.appendChild(script)
    }

    const loadStylesheet = (href, onLoad) => {
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = href
      link.onload = onLoad
      document.head.appendChild(link)
    }

    const options = {
      methods: ['wallets'],
      button: false,
      tooltip: false,
      fields: false,
      full_screen: false
    }

    const params = {
      merchant_id: 1523866,
      required_rectoken: 'y',
      currency: 'UAH',
      amount: cost * 100,
      order_desc: `Cablook Trip, ${new Date()}`,
      email: '',
      lang: 'uk'
    }

    loadStylesheet('https://pay.fondy.eu/latest/checkout.css', () => {
      loadScript('https://pay.fondy.eu/latest/checkout.js', () => {
        loadScript('https://pay.fondy.eu/latest/i18n/uk.js', () => {
          fondy('#fondy-container', { options, params })
            .$on('success', (model) => {
              document.getElementById('fondy-container').style.display = 'none'
              const order = model.attr('order')
              const approved = order.order_data.order_status == 'approved' && order.order_data.response_status == 'success'
              if (approved) createTrip({ target: { value: false } }, false, order)
            })
            .$on('error', (model) => {
              setButtonDisabled(false)
              console.log('Order is declined: ' + model.attr('error.code') + ', description: ' + model.attr('error.message'))
            })
        })
      })
    })
  }

  useEffect(() => {
    mobilePaymentScript()
    return () => { }
  }, [cost])

  return (
    <div>
      <div id='fondy-container'></div>
      {buttonDisabled &&
        <div className="loaderWrapper">
          <SearchLogo className="search_logo" />
        </div>
      }
    </div>

  )
}
