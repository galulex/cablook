if (navigator.serviceWorker) {
  navigator.serviceWorker.register('assets/serviceworker.js', { scope: './' })
    .then(function(reg) {
      console.log('[Companion]', 'Service worker registered!');
    });
}
