extends GutTest

## The ice rink as a place to raid (docs/diseno/allanamiento-pista.md, step 1): the rink on its lot, the ice that hardly
## grips, the boards that keep things on it, the locked office with its key in the till, the glass panels and the trophy
## case that break when something hits them fast, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func _prop(rink: Rink, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Rink.COCOA_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	rink.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_rink_has_its_ice_door_and_spots() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	assert_true(rink.office_door.locked)
	assert_true(rink.till.has_key, "the office's key is in the skate rental's till")
	assert_eq(rink.glass_left(), Rink.GLASS_XS.size())
	assert_true(Rink.on_ice(Rink.PENGUIN_AT) and Rink.on_ice(Rink.RESURFACER_AT), "the penguin and the resurfacer")
	assert_false(Rink.on_ice(Rink.RENTAL_AT))
	assert_eq(Rink.SPOTS.size(), 12)
	assert_eq(Rink.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Rink.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Rink.HALF_X, spot.id)
		assert_lt(absf(at.z), Rink.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
	for key: String in ["PLACE_RINK", "MENU_RINK", "RINK_GLASS_BROKEN", "RINK_TROPHIES_BROKEN", "RINK_LOST_AND_FOUND",
			"CASE_FAILED_LAWYER_RINK", "HINT_TILL_KEY_RINK"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_rink_stands_on_its_lot() -> void:
	var rink := _rink()
	await wait_physics_frames(1)
	assert_eq(CityLayout.place("rink").block, Vector2i(8, 3))
	assert_eq((rink.get_node("City") as Node3D).transform, CityLayout.anchor("rink"))


func test_something_pushed_on_the_ice_slides_far_and_on_the_floor_it_stops() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var on_ice := _prop(rink, Vector3(-6.0, Rink.ICE_TOP + 0.2, 0.0), Vector3(3.0, 0, 0))
	var on_floor := _prop(rink, Vector3(-6.0, Rink.FLOOR_TOP + 0.2, -12.0), Vector3(3.0, 0, 0))
	await wait_seconds(1.5)
	var ice_run := on_ice.global_position.x + 6.0
	var floor_run := on_floor.global_position.x + 6.0
	assert_gt(ice_run, floor_run * 2.0, "the ice keeps it going (%.2f m against %.2f m)" % [ice_run, floor_run])
	assert_lt(on_ice.global_position.y, Rink.ICE_TOP + 0.4, "on the ice, not under it")


func test_the_boards_keep_a_sliding_prop_on_the_ice() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var prop := _prop(rink, Vector3(0.0, Rink.ICE_TOP + 0.2, -6.0), Vector3(0, 0, -6.0))
	await wait_seconds(1.5)
	assert_gt(prop.global_position.z, Rink.ICE_Z0, "it bounced off the back boards")


func test_something_thrown_hard_at_a_glass_panel_breaks_it_once() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var at := Vector3(Rink.GLASS_XS[2], Rink.FLOOR_TOP + Rink.BOARD_HEIGHT + 0.6, Rink.ICE_Z1 - 2.0)
	_prop(rink, at, Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_eq(rink.glass_left(), Rink.GLASS_XS.size() - 1)
	assert_eq(rink.fines, Rink.GLASS_FINE)
	rink.break_glass(2)
	assert_eq(rink.fines, Rink.GLASS_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_trophy_case_but_a_fast_one_does() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var case_front := Rink.TROPHY_CASE_AT + Vector3(0, 1.2, -Rink.TROPHY_CASE_SIZE.z / 2)
	_prop(rink, case_front + Vector3(0, 0, -0.6), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(rink.trophies_cracked)
	_prop(rink, case_front + Vector3(0, 0, -2.5), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_true(rink.trophies_cracked)
	assert_eq(rink.fines, Rink.TROPHY_FINE * Rink.TROPHIES)


func test_the_till_key_opens_the_office() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	rink.till.use(cop)
	assert_true(cop.has_key)
	rink.office_door.use(cop)
	assert_false(rink.office_door.locked)
