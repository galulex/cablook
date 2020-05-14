import { h, render, Component } from 'preact'
import axios from 'axios'

import i18n from './i18n.js'
import './css/profile.css'
import Bonus from '../pwa/bonus_trips.js'
import Tabs from './tabs.js'

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props)
  }
  
  render() {
    return (
      <div>
        <header>{i18n.profile_page.header}</header>
        <section class='profile'>
          <Tabs
            favorite_addresses={() => this.props.favorite_addresses()}
            notification_settings={this.props.notification_settings}
            updateFavoriteAddresses={this.props.updateFavoriteAddresses}
            updateNotificationSettings={this.props.updateNotificationSettings}
            geocode={this.props.geocode}
            language={this.props.language}
            isGeocoding={this.props.isGeocoding}
            setGeocoding={this.props.setGeocoding}
            setAddress={this.setAddress}
            setLanguage={this.props.setLanguage}
          />
        </section>
      </div>
    )
  }

}
