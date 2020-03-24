const { environment } = require('@rails/webpacker')
const svelte = require('./loaders/svelte')
const path = require('path');

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

environment.config.resolve = {
    alias: {
			svelte: path.resolve('node_modules', 'svelte')
		},
		extensions: ['.mjs', '.js', '.svelte'],
		mainFields: ['svelte', 'browser', 'module', 'main']
}

environment.loaders.prepend('svelte', svelte)
module.exports = environment
