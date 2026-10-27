extends GutTest

## The bowling alley as a place to raid (docs/diseno/allanamiento-bolera.md, step 1): the alley on its lot with its six
## lanes and their pins, the locked office with its key in the shoe counter's till, the trophy case and the score
## screens that break, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley(case_seed := 5) -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.case_seed = case_seed
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	return alley


func _prop(alley: Bowling, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Bowling.PIN_MODEL, Vector3(0.22, 0.22, 0.22), 6.0)
	alley.add_child(prop)
	prop.global_position = alley.to_global(at)
	prop.linear_velocity = alley.global_basis * velocity
	return prop


func test_the_alley_has_its_door_till_and_spots() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_true(alley.office_door.locked)
	assert_true(alley.till.has_key, "the office's key is in the shoe counter's till")
	assert_eq(Bowling.SPOTS.size(), 12)
	assert_eq(Bowling.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Bowling.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Bowling.HALF_X, spot.id)
		assert_lt(absf(at.z), Bowling.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_alley_stands_on_its_lot() -> void:
	var alley := _alley()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("bowling").size.x > 0.0)
	assert_eq((alley.get_node("City") as Node3D).transform, CityLayout.anchor("bowling"))
	assert_true(PlaceDraw.PLACES.has("bowling"), "--place=bowling opens it")


func test_each_lane_has_its_ten_pins_standing() -> void:
	var alley := _alley()
	assert_eq(alley.pins.size(), 6)
	await wait_physics_frames(60)
	for lane: Array in alley.pins:
		assert_eq(lane.size(), 10)
		for pin: RigidBody3D in lane:
			assert_gt(pin.global_basis.y.dot(alley.global_basis.y), 0.95, "standing")


func test_something_thrown_hard_at_the_trophy_case_breaks_it_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	_prop(alley, Bowling.CASE_AT + Vector3(-1.5, 1.0, 0), Vector3(9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(alley.case_broken)
	assert_eq(alley.fines, Bowling.CASE_FINE)
	alley.break_trophy_case()
	assert_eq(alley.fines, Bowling.CASE_FINE, "only once")


func test_a_ball_flying_into_a_screen_breaks_that_one() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	_prop(alley, Vector3(Bowling.LANE_X[2], Bowling.SCREEN_Y, Bowling.SCREEN_Z + 1.5), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_eq(alley.broken_screens, [2] as Array[int])
	assert_eq(alley.fines, Bowling.SCREEN_FINE)
	alley.break_screen(2)
	assert_eq(alley.fines, Bowling.SCREEN_FINE, "only once a screen")


func test_the_till_key_opens_the_office() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	alley.till.use(cop)
	assert_true(cop.has_key)
	alley.office_door.use(cop)
	assert_false(alley.office_door.locked)
