extends GutTest

## The plant nursery as a place to raid (docs/diseno/allanamiento-vivero.md, step 1): the nursery on its lot, the
## greenhouse with the Dentuda's pot, the locked office with its key in the till, the greenhouse panes and the ceramic
## pots that break when something hits them fast, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func _prop(nursery: Nursery, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Nursery.CERAMIC_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	nursery.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_nursery_has_its_greenhouse_door_and_spots() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	assert_true(nursery.office_door.locked)
	assert_true(nursery.till.has_key, "the office's key is in the counter's till")
	assert_gt(nursery.panes.size(), 15, "the greenhouse is made of panes")
	assert_eq(nursery.pots.size(), Nursery.CERAMIC_POTS)
	assert_true(Nursery.in_greenhouse(Nursery.DENTUDA_AT), "the Dentuda lives in the greenhouse")
	assert_false(Nursery.in_greenhouse(Nursery.SPRINKLERS[0]), "the sprinklers are in the yard")
	assert_eq(Nursery.SPOTS.size(), 12)
	assert_eq(Nursery.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Nursery.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Nursery.HALF_X, spot.id)
		assert_lt(absf(at.z), Nursery.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
	for key: String in ["PLACE_NURSERY", "MENU_NURSERY", "NURSERY_GLASS_BROKEN", "NURSERY_POT_BROKEN",
			"CASE_FAILED_LAWYER_NURSERY", "HINT_TILL_KEY_NURSERY"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_nursery_stands_on_its_lot() -> void:
	var nursery := _nursery()
	await wait_physics_frames(1)
	assert_eq(CityLayout.place("nursery").block, Vector2i(7, 5))
	assert_eq((nursery.get_node("City") as Node3D).transform, CityLayout.anchor("nursery"))


func test_something_hidden_in_every_spot_stays_there() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var props: Array[Grabbable] = []
	for spot: Dictionary in Nursery.SPOTS:
		props.append(_prop(nursery, spot.at + Vector3.UP * 0.2, Vector3.ZERO))
	await wait_seconds(1.5)
	for i in props.size():
		var spot: Dictionary = Nursery.SPOTS[i]
		var at: Vector3 = spot.at
		assert_lt(props[i].global_position.distance_to(at + Vector3.UP * 0.15), 0.6, "%s keeps it" % spot.id)


func test_something_thrown_hard_at_a_pane_breaks_it_once_and_opens_a_hole() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var pane := nursery.panes[0].position
	_prop(nursery, pane + Vector3(0, 0, -2.0), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_eq(nursery.cracked, [0] as Array[int])
	assert_eq(nursery.fines, Nursery.PANE_FINE)
	nursery.break_pane(0)
	assert_eq(nursery.fines, Nursery.PANE_FINE, "only once")
	await wait_physics_frames(1)
	assert_true((nursery.panes[0].get_child(0) as CollisionShape3D).disabled, "you can walk through the hole")


func test_a_slow_prop_doesnt_break_a_pot_but_a_fast_one_does() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var pot := nursery.pots[0].position + Vector3(0, 0.2, 0)
	_prop(nursery, pot + Vector3(0, 0, -0.7), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(nursery.broken_pots.size(), 0)
	_prop(nursery, pot + Vector3(0, 0.1, -2.5), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_true(nursery.broken_pots.has(0))
	assert_false(nursery.pots[0].visible)
	assert_eq(nursery.fines, Nursery.POT_FINE * nursery.broken_pots.size())


func test_the_till_key_opens_the_office() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var cop: Cop = nursery.get_node("Cop")
	nursery.till.use(cop)
	assert_true(cop.has_key)
	nursery.office_door.use(cop)
	assert_false(nursery.office_door.locked)
