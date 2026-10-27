extends GutTest

## The ring highway around the city (persecucion-lugares.md, step 1): around the city with its ramps, the patrol
## car at 110 km/h on it, and the tolls whose barrier lifts for a car that stops and breaks for one that doesn't.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")
const CHASE_SCENE := preload("res://scenes/levels/chase.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	return cop


## The patrol car on the north side of the ring, in the lane going east, `x` along it.
func _on_the_ring(car: PatrolCar, city: Node3D, x: float) -> void:
	var lane := -HighwayLayout.HALF.y + HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE * 1.5
	car.global_transform = city.global_transform * Transform3D(Basis(Vector3.UP, PI / 2), Vector3(x, 0.3, lane))
	car.linear_velocity = Vector3.ZERO


func test_the_ring_goes_around_the_city_with_room_to_spare() -> void:
	var half := CityLayout.SIZE / 2
	for point in HighwayLayout.loop(-HighwayLayout.WIDTH / 2):
		var out := Vector2(maxf(absf(point.x) - half.x, 0.0), maxf(absf(point.z) - half.y, 0.0)).length()
		assert_gt(out, HighwayLayout.GAP - 7.0, "the inner edge stays about %d m away from the city" % HighwayLayout.GAP)
	assert_true(HighwayLayout.on_road(Vector3(0, 0, -HighwayLayout.HALF.y)), "the middle of the north side")
	assert_true(HighwayLayout.on_road(Vector3(HighwayLayout.HALF.x, 0, 0)), "the middle of the east side")
	assert_false(HighwayLayout.on_road(Vector3.ZERO), "the city isn't the highway")
	assert_false(HighwayLayout.on_road(Vector3(0, 0, -half.y)), "nor its edge street")
	var length := 0.0
	for piece in HighwayLayout.pieces():
		length += (piece[0] as Vector3).distance_to(piece[1])
	# 10 x 7 blocks since 26/10 (decision 181): the ring went from about 2 km to about 2.8 km.
	assert_between(length, 2600.0, 3000.0, "about 2.8 km around")


func test_each_ramp_runs_from_an_edge_street_to_the_ring() -> void:
	var half := CityLayout.SIZE / 2
	for side in HighwayLayout.SIDES:
		var ramp := HighwayLayout.ramp_rect(side)
		var rect := Rect2(Vector2(ramp[0].x, ramp[0].z) - ramp[1] / 2, ramp[1])
		var normal := CityLayout.side_normal(side)
		var length: float = ramp[1].y if side in ["n", "s"] else ramp[1].x
		var city_end: Vector3 = ramp[0] - normal * length / 2
		var ring_end := city_end + normal * (length + 0.5)
		assert_almost_eq(maxf(absf(city_end.x) - half.x, absf(city_end.z) - half.y), 0.0, 0.01,
			"%s starts at the city's edge" % side)
		assert_true(HighwayLayout.on_road(ring_end), "%s ends on the ring" % side)
		assert_almost_eq(rect.size.x if side in ["n", "s"] else rect.size.y, CityLayout.STREET, 0.01)
	for i in HighwayLayout.TOLLS.size():
		assert_true(HighwayLayout.on_road(HighwayLayout.toll_point(i)))


func test_the_hedge_opens_only_at_the_ramps() -> void:
	var city: Node3D = add_child_autofree(CITY_SCENE.instantiate())
	await wait_physics_frames(3)
	var space := city.get_world_3d().direct_space_state
	var half := CityLayout.SIZE / 2
	var ramp_x := CityLayout.street_x(HighwayLayout.RAMP_STREET_X)
	var ring := -HighwayLayout.HALF.y
	var free_way := PhysicsRayQueryParameters3D.create(Vector3(ramp_x, 1, -half.y + 4), Vector3(ramp_x, 1, ring))
	assert_true(space.intersect_ray(free_way).is_empty(), "down the north ramp onto the ring")
	var other := CityLayout.street_x(1)
	var blocked := PhysicsRayQueryParameters3D.create(Vector3(other, 1, -half.y + 4), Vector3(other, 1, ring))
	assert_false(space.intersect_ray(blocked).is_empty(), "elsewhere the hedge closes the city")
	var past := PhysicsRayQueryParameters3D.create(Vector3(0, 1, ring), Vector3(0, 1, ring - 40))
	assert_false(space.intersect_ray(past).is_empty(), "nobody drives off the far side of the ring")


func test_the_patrol_car_goes_110_on_the_highway_and_60_in_the_city() -> void:
	var city: Node3D = add_child_autofree(CITY_SCENE.instantiate())
	var car: PatrolCar = city.get_node("PatrolCar")
	assert_eq(car.top_speed(), PatrolCar.MAX_SPEED, "in the city")
	_on_the_ring(car, city, -240.0)
	await wait_physics_frames(20)
	assert_eq(car.top_speed(), PatrolCar.HIGHWAY_SPEED, "on the ring")
	var cop := _cop()
	car.enter(cop, 0)
	car.drive(1.0, 0.0, false)
	var fastest := 0.0
	for i in Engine.physics_ticks_per_second * 10:
		await wait_physics_frames(1)
		fastest = maxf(fastest, car.forward_speed())
	assert_gt(fastest, 95.0 / 3.6, "much faster than in the city")
	assert_lt(fastest, PatrolCar.HIGHWAY_SPEED + 1.0, "but no faster than 110")


func test_driving_through_the_toll_breaks_the_barrier_for_a_fine() -> void:
	var level: ChaseLevel = CHASE_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "ice_cream"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	var car := level.case.car
	var barrier: TollBarrier = level.get_node("City/Built/Highway/Toll/BarrierSouth")
	_on_the_ring(car, level.get_node("City"), HighwayLayout.TOLLS[0].x - 60.0)
	car.enter(level.get_node("Cop"), 0)
	car.drive(1.0, 0.0, false)
	for i in Engine.physics_ticks_per_second * 8:
		await wait_physics_frames(1)
		if barrier.is_broken:
			break
	assert_true(barrier.is_broken, "the car went through the lowered arm")
	assert_eq(level.case.damages.tolls, 1)
	assert_eq(level.case.damages.fines, ChaseDamages.FINE, "it costs a fine")


func test_stopping_at_the_booth_lifts_the_barrier() -> void:
	var city: Node3D = add_child_autofree(CITY_SCENE.instantiate())
	var car: PatrolCar = city.get_node("PatrolCar")
	var barrier: TollBarrier = city.get_node("Built/Highway/Toll/BarrierSouth")
	_on_the_ring(car, city, HighwayLayout.TOLLS[0].x - 3.0)
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_true(barrier.is_open, "stopped by the booth, the arm goes up")
	assert_false(barrier.is_broken)
	car.global_position += city.global_basis.x * 40.0
	await wait_physics_frames(roundi((TollBarrier.OPEN_SECONDS + 1.0) * Engine.physics_ticks_per_second))
	assert_false(barrier.is_open, "it comes down again once the car is gone")
