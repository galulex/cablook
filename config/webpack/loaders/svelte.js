module.exports = {
  rules: [
    {
      test: /\.(html|js)$/,
      exclude: /node_modules/,
      use: 'babel-loader'
    },
    {
      test: /\.(html|svelte)$/,
      use: {
        loader: 'svelte-loader',
        options: {
          hotReload: true,
          hotOptions: {
            noPreserveState: true
          }
        }
      }
    }
  ]
}
