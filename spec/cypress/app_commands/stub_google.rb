require 'fakeweb'
FakeWeb.allow_net_connect = true
body = File.read('spec/fixtures/maps/success_directions')
body_mapbox = File.read('spec/fixtures/maps/mapbox_success_directions')
FakeWeb.register_uri(:get, %r{https://maps.googleapis.com/maps/api/directions/.*}, body: body)
FakeWeb.register_uri(:get, %r{https://osrm.cablook.taxi/route/v1/driving/.*}, body: body_mapbox)
