import { h, render } from 'preact'
import Back from './images/arrow-left.svg'


export default function ControlButtons(props) {
  return (
    <div class='control-section'>
      <button type='button' class='button burger white-opacity' data-action='prev' onClick={e => scrollToItem(e, props.section)}><Back /></button>
      <button type='button' class='button burger white-opacity right-btn' data-action='next' onClick={e => scrollToItem(e, props.section)}><Back /></button>
    </div>
  )
}

function scrollToItem(e, section) {
  let positionCurrentContainer = section.scrollTop / section.offsetHeight
  let currentContainer = section.childNodes[positionCurrentContainer.toFixed()].firstElementChild
  let actions = { prev: '-', next: '+' }

  currentContainer.scrollTo({ left: eval(currentContainer.scrollLeft + actions[e.target.dataset.action] + currentContainer.offsetWidth), behavior: 'smooth' })
}
