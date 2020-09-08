import { h } from 'preact'

import i18n from './i18n.js'
import Upload from './images/upload.svg'
import AddThis from './images/addthis.svg'
import './css/prompt.css'

export default function Prompt(props) {
  let prompt = (window.ios && /^((?!chrome|android|crios|fxios).)*safari/i.test(navigator.userAgent) && ('standalone' in window.navigator && !window.navigator.standalone) && !localStorage.getItem('prompt'))

  if (prompt) return (
    <div class='prompt' onClick={(e) => { e.target.hidden = true; localStorage.setItem('prompt', true) }}>
      { i18n.prompt.install }
      <Upload />
      { i18n.prompt.and }
      <AddThis class='addthis' />
      { i18n.prompt.add }
    </div>
  )
}
