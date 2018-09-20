document.addEventListener('turbolinks:load', function(event) {
  var $page = $("[data-page='analytics']");
  if ($page.length > 0) {
    init();
  }
});

function init() {
  $('.js-trip').each(function(index, trip) {
    data = $(trip).data('trips');
    console.log(data);
  })
}