import { h, render, Component } from 'preact'
import i18n from '../i18n.js'

const LOCALES = { en: '🇺🇸', uk: '🇺🇦', ru: '🇷🇺' }

export default class Settings {
  render() {
    return (
      <div class='tab__holder'>
        <div class='tab__container'>
          <div class='nocall'>
            <input id='dark' type='checkbox' value='dark' onChange={this.changeTheme} checked={window.dark}/>
            <label for='dark'>{i18n.profile_page.theme}</label>
          </div>
          <div class='nocall lang'>
            <label for='language'>{i18n.profile_page.language}</label>
            <select onChange={this.props.setLanguage} id='language'>
              {Object.keys(LOCALES).map(key => {
                return(<option value={key} selected={key == this.props.language}>{LOCALES[key]}</option>)
              })}
            </select>
          </div>
        </div>
      </div>
    )
  }
}
