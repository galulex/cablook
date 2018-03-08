document.addEventListener("DOMContentLoaded", function(event) {
  var $page = $("[data-page='dashboard']");
  if ($page.length > 0) {
    init();
  }
});

var markers = [];

function init() {
  mapboxgl.accessToken = 'pk.eyJ1IjoiYnJ1Y2VsaWF0b3IiLCJhIjoiY2oxcTJ5dDNzMDA2ajMybnR6M3V5cGVubiJ9.qjyqnH72UUVnsaY63OzMGg';
  var map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/streets-v9',
      center: [32.05, 49.43],
      zoom: 12
  });

  $('.js-car').each(function(index, car) {
    data = $(car).data('info');

    var el = document.createElement('div');
    el.className = 'marker';
    el.setAttribute('data-info', JSON.stringify(data));
    el.addEventListener('click', function() {
    });

    var marker = new mapboxgl.Marker(el)
      .setLngLat([data.location[1], data.location[0]])
      .addTo(map);
    markers.push(marker);
  });

  subscribe();
}

function subscribe() {
  return this.ActionCable.createConsumer().subscriptions.create(
    { channel: 'DriverMapChannel' },
    { received: data => { if (data.action === 'SendLocation') { this.sendLocation(data) } } }
  )
}

function sendLocation(car) {
  el = markers.find(function(element, index, array) {
    if ($(markers[index]._element).data("info").id == car.car_id) {
      return element;
    }
  });

  if (el) {
    el.setLngLat([car.location[1], car.location[0]]);
  }
}
