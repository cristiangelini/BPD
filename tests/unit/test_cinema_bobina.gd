extends GutTest

## Doña Bobina and the projector (docs/diseno/allanamiento-cine.md, step 3): she comes down from her booth to the front
## of the theater filling the complaint, opening and locking its door on her way; cutting the tape sends her up to
## splice it, her back to everything (twice; the third cut she notices), and the spectators' "¡Shhh!" counts.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema() -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.case_seed = 5
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_she_comes_down_from_her_booth_and_locks_it_behind_her() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_eq(cinema.bobina.voice, "BOBINA")
	assert_true(cinema.booth_door.locked)
	await wait_until(func() -> bool: return cinema.booth_door.is_open, 6.0)
	assert_true(cinema.booth_door.is_open, "she opens it on her way out")
	await wait_until(func() -> bool: return cinema.to_local(cinema.bobina.global_position).z > -6.0, 20.0)
	var at := cinema.to_local(cinema.bobina.global_position)
	assert_gt(at.z, -6.0, "down the stair and into the aisle")
	assert_lt(at.y, Cinema.FLOOR_TOP + Cinema.RISE + 0.3)
	assert_false(cinema.booth_door.is_open, "she shut it")
	assert_true(cinema.booth_door.locked, "and locked it")


func test_cutting_the_tape_sends_her_to_splice_it_where_she_sees_nothing() -> void:
	var cinema := _cinema()
	cinema.bobina.fix_time = 1.0
	await wait_physics_frames(2)
	cinema.projector.print_copies()
	assert_false(cinema.film_running, "the screen goes white")
	await wait_until(func() -> bool: return cinema.bobina.is_fixing(), 10.0)
	assert_true(cinema.bobina.is_fixing(), "splicing at the back of the booth")
	assert_false(cinema.bobina.can_see(cinema.to_global(Vector3(-6.0, Cinema.BOOTH_FLOOR + 1.0, -11.0))),
		"her back to the window")
	await wait_until(func() -> bool: return not cinema.bobina.is_fixing(), 5.0)
	assert_true(cinema.film_running, "the film goes on")
	assert_gt(cinema.projector.rest_left, 0.0, "the projector rests")


func test_the_third_cut_she_notices() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	for i in CinemaProjector.TRICKS:
		cinema.projector.print_copies()
		cinema.projector.fix()
		cinema.projector.rest_left = 0.0
	var before := cinema.bobina.complaint
	cinema.projector.print_copies()
	assert_false(cinema.projector.is_jammed, "she doesn't come")
	assert_true(cinema.film_running)
	assert_almost_eq(cinema.bobina.complaint, before + Cinema.NOTICED, 0.01)


func test_a_shush_and_the_ripped_screen_go_on_her_complaint() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	cinema.spectators[0].shush()
	assert_almost_eq(cinema.bobina.complaint, Cinema.SHUSHED, 0.01)
	cinema.bobina.global_position = cinema.to_global(Vector3(-1.0, Cinema.FLOOR_TOP, 4.6))
	cinema.bobina.look_at(cinema.to_global(Cinema.SCREEN_AT), Vector3.UP, true)
	cinema.rip_screen()
	assert_almost_eq(cinema.bobina.complaint, Cinema.SHUSHED + Cinema.SAW_SCREEN, 0.01)
