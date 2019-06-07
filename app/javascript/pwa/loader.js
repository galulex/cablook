import { h, render, Component } from 'preact'
import SearchLogo from './images/search_logo.svg'

const Loader = () => (
  <div class='load-background'>
    <SearchLogo class='search_logo'/>
  </div>
)

export default Loader
