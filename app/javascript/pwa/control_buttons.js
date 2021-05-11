import { h, render } from 'preact'
import Back from './images/arrow-left.svg'


export default function ControlButtons(props) {
  return (
    <div style="width: 100%; position: absolute; top: 45%;">
      <button type='button' class='button burger white-opacity' style='top: 50%' data-action='prev' onClick={e => scrollToItem(e, props.section)}><Back /></button>
      <button type='button' class='button burger white-opacity right-btn' style='top: 50%' data-action='next' onClick={e => scrollToItem(e, props.section)}><Back /></button>
    </div>
  )
}

let scrollToItem = (e, section) => {
  let positionCurrentContainer = section.scrollTop / section.offsetHeight
  let currentContainer = section.childNodes[positionCurrentContainer.toFixed()]
  let actions = { prev: '-', next: '+' }

  currentContainer.scrollTo({ left: eval(currentContainer.scrollLeft + actions[e.target.dataset.action] + currentContainer.offsetWidth), behavior: 'smooth' })
}
