document.addEventListener('turbolinks:load', function(event) {
  var $page = $("[data-page='dashboard']");
  if ($page.length > 0) {
    if (typeof mapbox  === 'undefined') { loadMapbox(); }
    else { init(); }
  }
});

function loadMapbox() {
  var script = document.createElement('script');
  script.onload = function () { init(); }
  script.src = 'https://api.tiles.mapbox.com/mapbox-gl-js/v0.43.0/mapbox-gl.js';
  document.head.appendChild(script);
}

var map;
var markers = [];
var mapboxglToken = 'pk.eyJ1IjoiYnJ1Y2VsaWF0b3IiLCJhIjoiY2oxcTJ5dDNzMDA2ajMybnR6M3V5cGVubiJ9.qjyqnH72UUVnsaY63OzMGg';
var tripColors = ['#68efad', '#9b26af', '#FF5722', '#FFEB3B', '#18FFFF',
                  '#8BC34A', '#B388FF', '#E91E63', '#CDDC39', '#03A9F4',
                  '#02C8A7', '#675682', '#FE65B7', '#EC96A4', '#4484CE'];
var freeColors = [...tripColors];

function init() {
  mapboxgl.accessToken = mapboxglToken;
  map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/streets-v9',
      center: [32.05, 49.43],
      zoom: 12
  });

  $('.js-car').each(function(index, car) {
    data = $(car).data('info');
    var el = document.createElement('div');
    el.className = 'marker';
    el.innerHTML = $('.car-icon')[0].innerHTML;
    $('svg path:first-child', el).css('fill', data.color);
    if (data.color === 'white') {
      $(el).addClass('white');
    }
    el.setAttribute('data-info', JSON.stringify(data));
    el.addEventListener('click', function() {
    });

    popupHtml = `
      <h4>${data.number}</h4>
      <p>${data.status}</p>
      <p>${data.phone_number}</p>
      ${data.driver ? `<p>${data.driver.name}</p>` : ''}
    `

    marker = new mapboxgl.Marker(el)
      .setLngLat([data.location[1], data.location[0]])
      .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupHtml))
      .addTo(map);

    markers.push(marker);
  });

  $('.driver').each(function(index, driver){
    data = $(driver).data('drivers');
    var elt = document.createElement('div');
    elt.className = 'driver_marker';
    elt.setAttribute('style', 'background-color: #005b96; border: 1px solid black; height: 12px; width: 12px; border-radius: 50%;');
    elt.setAttribute('data-drivers', JSON.stringify(data));
    elt.addEventListener('click', function() {
    });

    popupHtml = `
      <h4>${data.name}</h4>
      <p>${data.username}</p>
      <p>${data.address}</p>
    `

    driver_marker = new mapboxgl.Marker(elt)
      .setLngLat([data.address_location[1], data.address_location[0]])
      .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupHtml))
      .addTo(map);
  });

  map.on('style.load', function () {
    $('.trips__card').each(function(index, trip) {
      tripData = $(trip).data('trip');
      subscribeToTripChannel(tripData.id);
      color = getTripColor();
      $(trip).css('background-color', color);
      drawRoute(color, tripData);
    });
  })

  window.cable = window.cable || subscribe();
}

function subscribe() {
  return this.ActionCable.createConsumer().subscriptions.create(
    { channel: 'DriverMapChannel' },
    { received: function(data) {
      if (data.action === 'SendLocation') { sendLocation(data); }
      else if (data.action === 'TripPropose') { addNewTrip(JSON.parse(data.trip)); }
    } }
  )
}

function subscribeToTripChannel(tripId) {
  return this.ActionCable.createConsumer().subscriptions.create(
    { channel: 'TripChannel', trip_id: tripId },
    { received: function(data) {
      tripId = JSON.parse(this.identifier).trip_id;
      if (['TripUnavailable', 'TripDeclined', 'finish_trip'].includes(data.action)) {
        this.unsubscribe();
        removeTrip(tripId);
      }
      else if (['TripAccepted', 'start_trip', 'waiting_client'].includes(data.action)) {
        newStatus = { TripAccepted: 'on_the_way', start_trip: 'driving', waiting_client: 'waiting_client' };
        updateTripStatus(tripId, newStatus[data.action]);
      }
    } }
  )
}

function sendLocation(car) {
  el = markers.find(function(element, index, array) {
    if ($(markers[index]._element).data('info').id == car.car_id) {
      return element;
    }
  });

  if (el) {
    el.setLngLat([car.location[1], car.location[0]]);
  }
}

function drawRoute(color, trip) {
  coordinates = polyline.decode(trip.path);
  map.addLayer({
    id: `route_${trip.id}`,
    type: 'line',
    source: {
      type: 'geojson',
      data: {
        type: 'Feature',
        geometry: {
          type: 'LineString',
          coordinates: coordinates
        }
      }
    },
    paint: {
      'line-width': 4,
      'line-color': color,
      'line-opacity': 0.8
    }
  });
}

function addNewTrip(trip) {
  subscribeToTripChannel(trip.id);
  color = getTripColor();
  $('.trips').append(cardMarkup(trip, color));
  drawRoute(color, trip);
}

function updateTripStatus(tripId, status) {
  el = getCard(tripId);
  $('.status', el).html(status);
}

function removeTrip(tripId) {
  el = getCard(tripId);
  $(el).slideUp();
  map.setLayoutProperty(`route_${tripId}`, 'visibility', 'none');
}

function getTripColor() {
  randomColor = freeColors[Math.floor(Math.random() * freeColors.length)];
  index = freeColors.indexOf(randomColor);
  freeColors.splice(index, 1);
  if (!freeColors.length) { freeColors = [...tripColors]; }
  return randomColor;
}

function getCard(tripId) {
  card = $.grep($('.trips__card'), function(el) {
    if ($(el).data('trip').id == tripId) {
      return el;
    }
  });
  return card;
}

function cardMarkup(trip, color) {
  tripJson = JSON.stringify({ id: trip.id });
  return `
    <li class='trips__card' style='background-color: ${color}' data-trip=${tripJson}>
      <div class='field'>
        <strong>Status:</strong>
        <span class='status'>pending</span>
      </div>
      <div class='field'>
        <strong>Departure:</strong>
        <span>${trip.departure_address}</span>
      </div>
      <div class='field'>
        <strong>Destination:</strong>
        <span'>${trip.destination_address}</span>
      </div>
      <div class='field'>
        <strong>Cost:</strong>
        <span'>${trip.cost}</span>
      </div>
      <div class='field'>
        <strong>User:</strong>
        <span'>${trip.user_number}</span>
      </div>
    </li>
  `
}
