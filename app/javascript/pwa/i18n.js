import en from './locales/en.js'
import ru from './locales/ru.js'
import uk from './locales/uk.js'

class i18n {
  constructor() {
    Object.assign(this, this.locales[localStorage.getItem('language') || this.interfaceLanguage])
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
