extends GutTest

## The karaoke as a place to raid (docs/diseno/allanamiento-karaoke.md, step 1): the karaoke on its lot with its stage,
## the locked office with its key in the bar's till, the lyrics screen and the disco ball that break, and the 12 hiding
## spots.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


func _prop(place: Karaoke, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Karaoke.CHAIRS_MODEL, Vector3(0.22, 0.22, 0.22), 2.0)
	prop.gravity_scale = 0.0
	place.add_child(prop)
	prop.global_position = place.to_global(at)
	prop.linear_velocity = place.global_basis * velocity
	return prop


func test_the_karaoke_has_its_door_till_and_spots() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_true(place.office_door.locked)
	assert_true(place.till.has_key, "the office's key is in the bar's till")
	assert_eq(Karaoke.SPOTS.size(), 12)
	assert_eq(Karaoke.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Karaoke.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Karaoke.HALF_X, spot.id)
		assert_lt(absf(at.z), Karaoke.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_karaoke_stands_on_its_lot() -> void:
	var place := _karaoke()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("karaoke").size.x > 0.0)
	assert_eq((place.get_node("City") as Node3D).transform, CityLayout.anchor("karaoke"))
	assert_true(PlaceDraw.PLACES.has("karaoke"), "--place=karaoke opens it")


func test_a_cop_walks_up_the_steps_onto_the_stage() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	var foot := Vector3(Karaoke.STEPS_X, Karaoke.FLOOR_TOP + 0.1, Karaoke.STAGE_AT.z + Karaoke.STAGE_SIZE.z / 2 + 2.2)
	cop.global_position = place.to_global(foot)
	cop.global_rotation.y = place.global_rotation.y
	await wait_physics_frames(10)
	for i in 120:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	var at := place.to_local(cop.global_position)
	assert_lt(at.z, Karaoke.STAGE_AT.z + Karaoke.STAGE_SIZE.z / 2 - 0.3, "on the stage")
	assert_gt(at.y, Karaoke.FLOOR_TOP + Karaoke.STAGE_SIZE.y - 0.1, "up on its boards")


func test_something_thrown_hard_at_the_lyrics_screen_breaks_it_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	_prop(place, Karaoke.SCREEN_AT + Vector3(0, 0, 2.5), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(place.screen_cracked)
	assert_eq(place.fines, Karaoke.SCREEN_FINE)
	place.break_screen()
	assert_eq(place.fines, Karaoke.SCREEN_FINE, "only once")


func test_something_thrown_at_the_disco_ball_brings_it_down() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	_prop(place, Karaoke.DISCO_AT + Vector3(0, 0, 2.5), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(place.disco_fallen)
	assert_eq(place.fines, Karaoke.DISCO_FINE)
	assert_false(place._disco.visible, "it's on the floor in pieces")


func test_the_till_key_opens_the_office() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	place.till.use(cop)
	assert_true(cop.has_key)
	place.office_door.use(cop)
	assert_false(place.office_door.locked)
