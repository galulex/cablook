document.addEventListener('turbolinks:load', function (event) {
  var $page = $("[data-page='dashboard']");
  if ($page.length > 0) {
    if (typeof mapbox === 'undefined') {
      loadMapbox();
    } else {
      init();
    }
  }
});

function loadMapbox() {
  var script = document.createElement('script');
  script.onload = function () {
    init();
  };
  script.src = 'https://api.mapbox.com/mapbox-gl-js/v1.13.0/mapbox-gl.js';
  document.head.appendChild(script);
}

var map;
var markers = [];
var mapboxglToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA';
var tripColors = ['#68efad', '#9b26af', '#FF5722', '#FFEB3B', '#18FFFF', '#8BC34A', '#B388FF', '#E91E63', '#CDDC39', '#03A9F4', '#02C8A7', '#675682', '#FE65B7', '#EC96A4', '#4484CE'];
var freeColors = [].concat(tripColors);

function init() {
  mapboxgl.accessToken = mapboxglToken;
  map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/streets-v9',
    center: [32.05, 49.43],
    zoom: 12
  });

  $('.js-car').each(function (index, car) {
    data = $(car).data('info');
    var el = document.createElement('div');
    el.className = 'marker';
    el.innerHTML = $('.car-icon')[0].innerHTML;
    $('svg path:first-child', el).css('fill', data.color);
    if (data.color === 'white') {
      $(el).addClass('white');
    }
    el.setAttribute('data-info', JSON.stringify(data));
    el.addEventListener('click', function () {});

    popupHtml = '\n      <h4>' + data.number + '</h4>\n      <p>' + data.status + '</p>\n      <p>' + data.phone_number + '</p>\n      ' + (data.driver ? '<p>' + data.driver.name + '</p>' : '') + '\n    <p class="car_' + data.id +'" style="display: none;"></p>';

    marker = new mapboxgl.Marker(el).setLngLat([data.location[1], data.location[0]]).setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupHtml)).addTo(map);

    markers.push(marker);
  });

  $('.driver').each(function (index, driver) {
    data = $(driver).data('drivers');
    var elt = document.createElement('div');
    elt.className = 'driver_marker';
    elt.setAttribute('style', 'background-color: #005b96; border: 1px solid black; height: 12px; width: 12px; border-radius: 50%;');
    elt.setAttribute('data-drivers', JSON.stringify(data));
    elt.addEventListener('click', function () {});

    popupHtml = '\n      <h4>' + data.name + '</h4>\n      <p>' + data.username + '</p>\n      <p>' + data.address + '</p>\n    ';

    driver_marker = new mapboxgl.Marker(elt).setLngLat(data.address_location.reverse()).setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupHtml)).addTo(map);
  });

  map.on('style.load', function () {
    $('.trips__card').each(function (index, trip) {
      tripData = $(trip).data('trip');
      subscribeToTripChannel(tripData.id);
      color = getTripColor();
      $(trip).css('background-color', color);
      drawRoute(color, tripData);
    });
  });

  window.cable = window.cable || subscribe();
}

function subscribe() {
  return this.ActionCable.createConsumer().subscriptions.create({ channel: 'DriverMapChannel' }, { received: function received(data) {
      if (data.action === 'SendLocation') {
        sendLocation(data);
      } else if (data.action === 'TripPropose') {
        addNewTrip(JSON.parse(data.trip));
      }
    } });
}

function subscribeToTripChannel(tripId) {
  return this.ActionCable.createConsumer().subscriptions.create({ channel: 'TripChannel', trip_id: tripId }, { received: function received(data) {
      tripId = JSON.parse(this.identifier).trip_id;
      if (['TripUnavailable', 'TripDeclined', 'finish_trip'].includes(data.action)) {
        this.unsubscribe();
        removeTrip(tripId);
      } else if (['TripAccepted', 'start_trip', 'waiting_client'].includes(data.action)) {
        updateTripStatus(tripId, data);
      }
    } });
}

function sendLocation(car) {
  el = markers.find(function (element, index, array) {
    if ($(markers[index]._element).data('info').id == car.car_id) {
      return element;
    }
  });

  if (el) {
    el.setLngLat([car.location[1], car.location[0]]);
    car_speed = $('.car_' + car.car_id);
    car_speed.text(car.speed + ' km/h');
    if (car_speed.is(':hidden')) car_speed.show();
  }
}

function drawRoute(color, trip) {
  coordinates = polyline.decode(trip.path);
  map.addLayer({
    id: 'route_' + trip.id,
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

function updateTripStatus(tripId, data) {
  el = getCard(tripId);
  $('.status', el).html(data.trip.status);
  $('.name', el).html(data.driver.name);
  $('.car-number', el).html(data.driver.car.number);
  $('.start-time', el).html(data.trip.start_time);
}

function removeTrip(tripId) {
  el = getCard(tripId);
  $(el).slideUp();
  map.setLayoutProperty('route_' + tripId, 'visibility', 'none');
}

function getTripColor() {
  randomColor = freeColors[Math.floor(Math.random() * freeColors.length)];
  index = freeColors.indexOf(randomColor);
  freeColors.splice(index, 1);
  if (!freeColors.length) {
    freeColors = [].concat(tripColors);
  }
  return randomColor;
}

function getCard(tripId) {
  card = $.grep($('.trips__card'), function (el) {
    if ($(el).data('trip').id == tripId) {
      return el;
    }
  });
  return card;
}

function cardMarkup(trip, color) {
  tripJson = JSON.stringify({ id: trip.id });
  return '\n    <li class=\'trips__card\' style=\'background-color: ' + color + '\' data-trip=' + tripJson + '>\n      <div class=\'field\'>\n        <strong>Status:</strong>\n        <span class=\'status\'>pending</span>\n      </div>\n      <div class=\'field\'>\n        <strong>Departure:</strong>\n        <span>' + trip.departure_address + '</span>\n      </div>\n      <div class=\'field\'>\n        <strong>Destination:</strong>\n        <span\'>' + trip.destination_address + '</span>\n      </div>\n      <div class=\'field\'>\n        <strong>Cost:</strong>\n        <span\'>' + trip.cost + '</span>\n      </div>\n      <div class=\'field\'>\n        <strong>User:</strong>\n        <span\'>' + trip.user_number + '</span>\n      </div>\n      <div class=\'field\'>\n        <strong>Start time:</strong>\n        <span\'>' + trip.start_at + '</span>\n      </div>\n    </li>\n  ';
}
