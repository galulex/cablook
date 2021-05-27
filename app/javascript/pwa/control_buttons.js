import { h, render } from 'preact'
import Back from './images/arrow-left.svg'


export default function ControlButtons(props) {
  return (
    <div class='control-section'>
      <button type='button' class='button burger white-opacity' onClick={() => scrollToItem(props.section, 'prev')}><Back /></button>
      <button type='button' class='button burger white-opacity right-btn' onClick={() => scrollToItem(props.section, 'next')}><Back /></button>
    </div>
  )
}

function scrollToItem(section, action) {
  let positionCurrentContainer = section.scrollTop / section.offsetHeight
  let currentContainer = section.childNodes[positionCurrentContainer.toFixed()].firstElementChild
  let actions = { prev: '-', next: '+' }

  currentContainer.scrollTo({ left: eval(currentContainer.scrollLeft + actions[action] + currentContainer.offsetWidth), behavior: 'smooth' })
}
