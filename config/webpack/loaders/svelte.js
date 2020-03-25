module.exports = {
  rules: [
    {
      test: /\.(html|js)$/,
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
