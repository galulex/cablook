import en from './locales/en.js'
import ru from './locales/ru.js'
import uk from './locales/uk.js'

class i18n {
  constructor() {
    let locale = this.locales[localStorage.getItem('language') || this.interfaceLanguage.split('-')[0]]
    Object.keys(locale).forEach(key => {
      if (!this[key]) this[key] = locale[key]
    })
    return this
  }

  get locales() {
    return { en: en, ru: ru, uk: uk }
  }

  get interfaceLanguage() {
    return (navigator.languages && navigator.languages.length) ? navigator.languages[0] : navigator.userLanguage || navigator.language || navigator.browserLanguage || 'en';
  }
}

export default new i18n()
