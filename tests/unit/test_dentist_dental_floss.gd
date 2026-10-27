extends GutTest

## The dental office raid with the dental floss story (allanamiento-dentista.md, step 6): the crate of reels and its
## extras hidden with the seed, the taut threads across the corridor that trip a running cop (not a walking one) and
## the rope of floss at the corridor's window as the story's clue.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "dental_floss"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


## Puts the cop in the corridor just west of `x`, then a frame later just east of it.
func _cross(office: DentistRaid, x: float) -> Cop:
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(Vector3(x - 0.2, DentistRaid.FLOOR_TOP + 0.05, 2.0))
	await wait_physics_frames(1)
	cop.global_position = office.to_global(Vector3(x + 0.2, DentistRaid.FLOOR_TOP + 0.05, 2.0))
	await wait_physics_frames(2)
	return cop


func test_the_crate_and_its_extras_are_hidden() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_has(office.raid.suspicions, "dental_floss")
	assert_true(office.rig is DentalFlossRig)
	assert_eq(office.main, office.hidden[0])
	assert_almost_eq((office.main as RigidBody3D).mass, 6.0, 0.01)
	assert_true(DentistRaid.SPOTS[office.hidden_spots[0]].heavy)
	assert_eq(office.extras.size(), 2, "the hook and the plan")


func test_the_threads_are_drawn_with_the_seed() -> void:
	var office := _office()
	var other := _office(6)
	await wait_physics_frames(2)
	var rig := office.rig as DentalFlossRig
	assert_eq(rig.thread_xs.size(), DentalFlossRig.THREADS)
	for x in rig.thread_xs:
		assert_has(DentalFlossRig.THREAD_XS, x)
	assert_ne(rig.thread_xs, (other.rig as DentalFlossRig).thread_xs, "another seed, other threads")


func test_a_running_cop_trips_and_drops_what_it_holds() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as DentalFlossRig
	var cop: Cop = office.get_node("Cop")
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(office.candies[0])
	cop.is_running = true
	await _cross(office, rig.thread_xs[0])
	assert_eq(rig.trips, 1)
	assert_true(cop.is_staggered(), "down on the floor")
	assert_null(grabber.held, "it drops what it held")


func test_a_walking_cop_steps_over_them() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as DentalFlossRig
	var cop: Cop = office.get_node("Cop")
	cop.is_running = false
	await _cross(office, rig.thread_xs[0])
	assert_eq(rig.trips, 0)
	assert_false(cop.is_staggered())


func test_crossing_only_counts_on_the_floor_of_the_corridor() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as DentalFlossRig
	var x := rig.thread_xs[0]
	var f := DentistRaid.FLOOR_TOP
	assert_eq(rig.crossed(Vector3(x - 0.1, f, 2.0), Vector3(x + 0.1, f, 2.0)), 0)
	assert_eq(rig.crossed(Vector3(x - 0.1, f + 1.0, 2.0), Vector3(x + 0.1, f + 1.0, 2.0)), -1, "jumping over")
	assert_eq(rig.crossed(Vector3(x - 0.1, f, 5.0), Vector3(x + 0.1, f, 5.0)), -1, "in the waiting room")
	assert_eq(rig.crossed(Vector3(x + 0.1, f, 2.0), Vector3(x + 0.3, f, 2.0)), -1, "not across it")


func test_the_rope_at_the_window_is_a_clue_once() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as DentalFlossRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(Vector3(-DentistRaid.HALF_X + 1.0, DentistRaid.FLOOR_TOP + 0.05, 2.0))
	await wait_physics_frames(2)
	assert_true(rig.saw_rope)
	assert_has(office.raid.clues_found, tr("CLUE_FLOSS_ROPE"))
	var clues: int = office.raid.clues_found.size()
	await wait_physics_frames(3)
	assert_eq(office.raid.clues_found.size(), clues, "only once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_DENTAL_FLOSS_B", "BRIEF_DENTAL_FLOSS_C", "BRIEF_DENTAL_FLOSS_D", "OBJ_FIND_FLOSS_REELS",
			"OBJ_EXTRA_CLIMBING_HOOK", "OBJ_EXTRA_PRISON_PLAN", "LUCHO_CLUE_dental_floss", "CLUE_FLOSS_ROPE",
			"HINT_FLOSS_TRIP"]:
		assert_ne(tr(key), key, "%s is translated" % key)
