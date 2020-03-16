module.exports = {
  rules: [
    {
      test: /\.svelte$/,
      exclude: /node_modules\/(?!svelte)/,
      use: [
        { //babel loader after the svelte loader
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          }
        },
        { //svelte loader first
          loader: 'svelte-loader',
          options: {
            hydratable: true
          }
        }
      ]
    },
    {
      test: /\.js$/,
      loader: 'babel-loader',
      exclude: [/node_modules\/(?!svelte)/, /\.legacy.js$/],
      options: {
        presets: [['@babel/preset-env', { modules: false }]],
      },
    },
  ]
}
