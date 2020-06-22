import { h } from 'preact'
import Star from '../images/star.svg'

export default function getRate(rate) {
  let stars = Array(5)
  for(let i = 1; i <= 5; i++) {
    let star = <Star class={`star-icon ${i > rate ? ' blank' : ''}`} />
    stars.push(star)
  }
  return stars
}
