const { environment } = require('@rails/webpacker')
const svelte = require('./loaders/svelte')

environment.loaders.insert('svg', {
        test: /\.svg$/,
        use: ['preact-svg-loader'],
    }, { after: 'file' })

const fileLoader = environment.loaders.get('file')
fileLoader.exclude = /\.(svg)$/i

environment.loaders.insert('css', {
  test: /\.css$/,
  use: ['style-loader', 'css-loader']
})

environment.loaders.prepend('svelte', svelte)
module.exports = environment
