extends GutTest

## The highway chase's traffic and radio (persecucion-lugares.md, "En la autopista"): slow cars both ways that move
## over for the suspect, cost a fine when hit and have the toll tag; and backup that never comes.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level(suspect := "highway") -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = suspect
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _local(level: ChaseLevel, world: Vector3) -> Vector3:
	return level.case.city_transform.affine_inverse() * world


func test_ten_slow_cars_drive_the_ring_half_each_way() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var traffic := level.case.highway.traffic
	assert_eq(traffic.size(), ChaseHighway.TRAFFIC)
	var starts: Array[Vector3] = []
	for car in traffic:
		assert_true(HighwayLayout.on_road(_local(level, car.global_position)), "%s starts on the ring" % car.name)
		starts.append(car.global_position)
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	var outer := 0
	for k in traffic.size():
		var car := traffic[k]
		var local := _local(level, car.global_position)
		assert_true(HighwayLayout.on_road(local), "%s stays on the ring" % car.name)
		var speed := Vector2(car.global_position.x - starts[k].x, car.global_position.z - starts[k].z).length() / 2.0
		assert_almost_eq(speed, TrafficCar.SPEED, 2.0, "%s goes about 50 km/h" % car.name)
		if maxf(absf(local.x) / HighwayLayout.HALF.x, absf(local.z) / HighwayLayout.HALF.y) > 1.0:
			outer += 1
	assert_eq(outer, ChaseHighway.TRAFFIC / 2, "half of them the other way, across the median")


func test_no_traffic_in_the_city_chases() -> void:
	var level := _level("ice_cream")
	await wait_physics_frames(5)
	assert_null(level.case.highway)
	assert_eq(get_tree().get_nodes_in_group("traffic").size(), 0)


func test_a_car_moves_over_when_the_suspect_comes_up_behind() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var car := level.case.highway.traffic[0]
	var lane := car.lane
	level.truck.global_position = car.global_position - car.global_basis.z * 15.0
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	assert_ne(car.lane, lane, "it moved over to the other lane")
	var off := HighwayLayout.off_middle(_local(level, car.global_position))
	var other := absf(HighwayRoute.FAST_LANE if lane == 0 else HighwayRoute.SLOW_LANE)
	assert_almost_eq(off, other, 1.2, "and it's in it already")


func test_hitting_a_car_of_the_traffic_is_a_crash() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var other := case.highway.traffic[0]
	var parked: Array[PackedVector3Array] = []
	other.lanes = parked
	var patrol := case.car
	patrol.global_transform = Transform3D(other.global_basis, other.global_position - other.global_basis.z * 9.0 + Vector3.UP * 0.3)
	await wait_physics_frames(3)
	patrol.linear_velocity = other.global_basis.z * 20.0
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_eq(case.damages.crashes, 1, "a crash")
	assert_eq(case.damages.fines, ChaseDamages.FINE)


func test_the_traffic_has_the_toll_tag() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var barrier: TollBarrier = level.get_node("City/Built/Highway/Toll/BarrierSouth")
	var car := level.case.highway.traffic[0]
	var lane := -HighwayLayout.HALF.y - HighwayRoute.SLOW_LANE
	var line := PackedVector3Array([level.case.city_transform * Vector3(HighwayLayout.TOLLS[0].x - 40.0, 0, lane),
		level.case.city_transform * Vector3(HighwayLayout.TOLLS[0].x + 300.0, 0, lane)])
	var lanes: Array[PackedVector3Array] = [line, line]
	car.lanes = lanes
	car.place(0, 0)
	var lifted := false
	for i in Engine.physics_ticks_per_second * 5:
		await wait_physics_frames(1)
		lifted = lifted or barrier.is_open
	assert_true(lifted, "the arm went up for it without it stopping")
	assert_false(barrier.is_broken)
	assert_gt(_local(level, car.global_position).x, HighwayLayout.TOLLS[0].x + 10.0, "it went through the toll")


func test_backup_never_comes_but_the_excuses_change() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var radio := level.case.highway
	TranslationServer.set_locale("es")
	var heard: Array[String] = []
	for i in ChaseHighway.EXCUSES:
		radio._cooldown = 0.0
		var excuse := radio.call_backup()
		assert_ne(tr(excuse), excuse, "%s needs a text" % excuse)
		assert_false(heard.has(excuse), "a new excuse each time")
		heard.append(excuse)
	assert_eq(radio.call_backup(), "", "the radio is still busy")
	assert_ne(tr("HINT_CHASE_BACKUP"), "HINT_CHASE_BACKUP")
