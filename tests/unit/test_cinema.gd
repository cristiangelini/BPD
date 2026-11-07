extends GutTest

## The cinema as a place to raid (docs/diseno/allanamiento-cine.md, step 1): the cinema on its lot, the 40 seats on the
## slope down to the screen, the locked projection booth with its key in the till, the screen and the popcorn machine's
## glass that break when something hits them fast, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func _prop(cinema: Cinema, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Cinema.POPCORN_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	cinema.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_cinema_has_its_seats_door_and_spots() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_eq(cinema.seats.size(), 40)
	assert_lt(cinema.seats[0].y, cinema.seats[-1].y, "the front row is lower: the floor rises toward the back")
	assert_true(cinema.booth_door.locked)
	assert_true(cinema.till.has_key, "the booth's key is in the ticket booth's till")
	assert_eq(Cinema.SPOTS.size(), 12)
	assert_eq(Cinema.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Cinema.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Cinema.HALF_X, spot.id)
		assert_lt(absf(at.z), Cinema.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
	for id: String in ["under_seat_row_3", "under_seat_row_6"]:
		var spot: Dictionary = Cinema.SPOTS.filter(func(s: Dictionary) -> bool: return s.id == id)[0]
		assert_almost_eq(spot.at.y, Cinema.floor_at(spot.at.z), 0.01, "%s lies on the slope" % id)


func test_the_cinema_stands_on_its_lot() -> void:
	var cinema := _cinema()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("cinema").size.x > 0.0)
	assert_eq((cinema.get_node("City") as Node3D).transform, CityLayout.anchor("cinema"))


func test_something_dropped_in_the_theater_rolls_to_the_slope() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var prop := _prop(cinema, Vector3(-9.5, 2.5, 0.0), Vector3.ZERO)
	await wait_physics_frames(60)
	assert_almost_eq(prop.global_position.y, Cinema.floor_at(prop.global_position.z) + 0.15, 0.2, "on the slope")


func test_something_thrown_hard_at_the_screen_rips_it_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	_prop(cinema, Cinema.SCREEN_AT + Vector3(0, 0, -3.0), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_true(cinema.screen_torn)
	assert_eq(cinema.fines, Cinema.SCREEN_FINE)
	cinema.rip_screen()
	assert_eq(cinema.fines, Cinema.SCREEN_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_popcorn_glass_but_a_fast_one_does() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	_prop(cinema, Cinema.POPCORN_AT + Vector3(0, 1.3, 0), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(cinema.glass_cracked)
	_prop(cinema, Cinema.POPCORN_AT + Vector3(0, 0.5, 2.0), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(cinema.glass_cracked)
	assert_eq(cinema.fines, Cinema.GLASS_FINE)


func test_the_till_key_opens_the_booth() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var cop: Cop = cinema.get_node("Cop")
	cinema.till.use(cop)
	assert_true(cop.has_key)
	cinema.booth_door.use(cop)
	assert_false(cinema.booth_door.locked)
