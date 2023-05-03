import { h } from 'preact'
import '../css/welcome_popup.css'

export default function WelcomePopup(props) {
  let { message, onClose } = props

  return(
    <div className="popup-container">
      <div className="popup">
        <div className="popup-message">{message}</div>
        <button className="popup-close" onClick={onClose}>Ok!</button>
      </div>
    </div>
  )
}
