const { environment } = require('@rails/webpacker')

environment.loaders.insert('svg', {
        test: /\.svg$/,
        use: ['preact-svg-loader'],
    }, { after: 'file' })

const fileLoader = environment.loaders.get('file')
fileLoader.exclude = /\.(svg)$/i

module.exports = environment
