extends GutTest

## The train's clock (escena-tren.md, step 1; TrainRide).


func test_five_stations_with_a_tunnel_between_each() -> void:
	var ride := TrainRide.new()
	assert_eq(ride.next_station(), 0)
	assert_false(ride.stopped())
	assert_almost_eq(ride.speed(), 0.0, 0.01, "it leaves from standing")
	var stations := 0
	var tunnels := 0
	var was_stopped := false
	var was_tunnel := false
	var last := 0.0
	while not ride.arrived():
		ride.advance(0.5)
		assert_true(ride.distance() >= last, "the train never goes back")
		last = ride.distance()
		if ride.stopped() and not was_stopped:
			stations += 1
			assert_almost_eq(ride.distance(), TrainRide.station_at(ride.next_station()), 0.5, "it stops at the platform")
		if ride.in_tunnel() and not was_tunnel:
			tunnels += 1
			assert_almost_eq(ride.speed(), TrainRide.SPEED, 0.01, "at full speed in the tunnel")
		was_stopped = ride.stopped()
		was_tunnel = ride.in_tunnel()
	assert_eq(stations, TrainRide.STATIONS)
	assert_eq(tunnels, TrainRide.STATIONS)
	assert_eq(ride.next_station(), TrainRide.STATIONS - 1, "the last one")
	assert_almost_eq(ride.time, 5 * 120.0 + 4 * 20.0, 0.01, "five legs of 2 min and four stops")
	ride.advance(10.0)
	assert_true(ride.arrived(), "and the end of the line is the end")
