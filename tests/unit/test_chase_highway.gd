extends GutTest

## The sports car on the highway (persecucion-lugares.md, "En la autopista"): to the nearest ramp through the city,
## then laps of the ring at 90 km/h in the right-hand lanes, through the tolls' barriers; the meter allows more room.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")
const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "highway"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


## The first point of his path that is on the ring.
func _first_on_ring(car: SuspectCar, city: Node3D) -> int:
	for k in car.points.size():
		if HighwayLayout.on_road(city.global_transform.affine_inverse() * car.points[k]):
			return k
	return -1


func test_he_drives_to_the_nearest_ramp_then_around_the_ring_clockwise() -> void:
	var start := ChaseRoute.nearest_corner(CityLayout.parking("station").origin)
	var side := HighwayRoute.nearest_ramp(start)
	var corners := HighwayRoute.city_corners(start, side)
	assert_eq(corners[0], start)
	assert_eq(corners[corners.size() - 1], HighwayRoute.ramp_corner(side), "the streets end at the ramp")
	for k in range(1, corners.size()):
		assert_eq(absi(corners[k].x - corners[k - 1].x) + absi(corners[k].y - corners[k - 1].y), 1, "a block at a time")
	var path := HighwayRoute.draw(7, start)
	var ring := path.filter(func(p: Vector3) -> bool: return HighwayLayout.on_road(p))
	assert_gt(ring.size(), 100, "laps of the ring")
	for p: Vector3 in ring:
		var lane := HighwayLayout.off_middle(p)
		assert_between(lane, HighwayLayout.MEDIAN / 2, HighwayLayout.WIDTH / 2, "in a lane, not on the median")
		assert_lt(maxf(absf(p.x) / HighwayLayout.HALF.x, absf(p.z) / HighwayLayout.HALF.y), 1.0, "the inner half")
	# Clockwise seen from above: on the north side he goes east.
	var north: Array = []
	for k in path.size() - 1:
		if path[k].z < -HighwayLayout.HALF.y + HighwayLayout.WIDTH and path[k + 1].z < -HighwayLayout.HALF.y + HighwayLayout.WIDTH:
			north.append(path[k + 1].x - path[k].x)
	assert_gt(north.size(), 0)
	assert_true(north.all(func(dx: float) -> bool: return dx > -0.01), "east along the north side")


func test_ninety_on_the_ring_fifty_in_the_city() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var car := level.truck
	var city: Node3D = level.get_node("City")
	assert_eq(car.kind, "highway")
	assert_almost_eq(car.top_speed(), SuspectCar.HIGHWAY_CITY_SPEED, 0.01, "in the city")
	var k := _first_on_ring(car, city) + 3
	car.global_position = car.points[k - 1] + Vector3.UP * 0.2
	var ahead := car.points[k] - car.points[k - 1]
	car.rotation.y = atan2(ahead.x, ahead.z)
	car.next = k
	level.case.give_tip()
	level.case.car.enter(level.get_node("Cop"), 0)
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_almost_eq(car.top_speed(), SuspectCar.HIGHWAY_SPEED, 0.01, "on the ring")
	var from := car.global_position
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	var speed := Vector2(car.global_position.x - from.x, car.global_position.z - from.z).length() / 2.0
	assert_gt(speed, 70.0 / 3.6, "about 90 km/h")
	assert_almost_eq(level.case.far(), ChaseCase.HIGHWAY_FAR, 0.01, "the meter gives more room out here")


func test_he_breaks_the_toll_barrier_without_a_fine() -> void:
	var city: Node3D = add_child_autofree(CITY_SCENE.instantiate())
	await wait_physics_frames(3)
	var barrier: TollBarrier = city.get_node("Built/Highway/Toll/BarrierSouth")
	var car := SuspectCar.new()
	car.kind = "highway"
	city.add_child(car)
	var lane := -HighwayLayout.HALF.y - HighwayRoute.SLOW_LANE
	var path: Array[Vector3] = [Vector3(HighwayLayout.TOLLS[0].x - 50.0, 0.2, lane),
		Vector3(HighwayLayout.TOLLS[0].x + 200.0, 0.2, lane)]
	car.follow_path(path, city.global_transform)
	var by: Array[Node3D] = []
	barrier.broken.connect(func(who: Node3D) -> void: by.append(who))
	for i in Engine.physics_ticks_per_second * 6:
		await wait_physics_frames(1)
		if barrier.is_broken:
			break
	assert_true(barrier.is_broken, "he drives straight through it")
	assert_eq(by, [car] as Array[Node3D])


func test_the_megaphone_doesnt_change_his_mind() -> void:
	var level := _level()
	await wait_physics_frames(5)
	level.case.truck.next = 2
	assert_false(level.case.tasks.wrong_turn(), "he knows where he's going")
	assert_almost_eq(level.case.far(), ChaseCase.FAR, 0.01, "in the city the meter is the usual one")
