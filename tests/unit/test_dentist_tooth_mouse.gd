extends GutTest

## The dental office raid with the tooth mouse story (allanamiento-dentista.md, step 6): the jar of baby teeth and its
## extras, the talc prints into the office as the story's clue, and the wind-up mouse that carries small things from
## the floor to under the furniture.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "tooth_mouse"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_jar_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_has(office.raid.suspicions, "tooth_mouse")
	assert_eq(office.main, office.hidden[0])
	assert_almost_eq((office.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(office.extras.size(), 2, "the costume and the map")
	assert_true(office.rig is ToothMouseRig)


func test_the_talc_prints_lead_to_the_office_and_the_first_time_close_is_a_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ToothMouseRig
	assert_gt(rig.prints.size(), 10)
	assert_lt(rig.prints[-1].z, DentistRaid.ROOMS_Z, "the last ones inside the office")
	assert_gt(rig.prints[-1].x, DentistRaid.ROOM_WALLS[2])
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(Vector3(8.25, 0.1, 1.8))
	await wait_physics_frames(2)
	assert_true(rig.saw_prints)
	assert_has(office.raid.clues_found, tr("CLUE_TALC_PRINTS"))


func test_the_mouse_runs_its_round() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ToothMouseRig
	var start := rig.mouse.position
	await wait_seconds(1.0)
	assert_gt(rig.mouse.position.distance_to(start), 0.5)
	assert_eq(rig.net_state()[0], rig.mouse.position)


func test_the_mouse_carries_a_small_thing_under_the_furniture() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ToothMouseRig
	var candy: Grabbable = office.candies[0]
	# Just before the reception: the next stop is under it.
	rig.mouse.position = ToothMouseRig.ROUTE[4]
	rig._next = 4
	candy.global_position = office.to_global(ToothMouseRig.ROUTE[4] + Vector3.UP * 0.05)
	await wait_physics_frames(3)
	assert_eq(rig.carrying, candy, "it picks it up")
	await wait_seconds(1.5)
	assert_null(rig.carrying)
	assert_eq(rig.carried, 1)
	var at := office.to_local(candy.global_position)
	assert_lt(Vector2(at.x, at.z).distance_to(Vector2(ToothMouseRig.ROUTE[5].x, ToothMouseRig.ROUTE[5].z)), 0.3,
		"left under the reception")


func test_it_does_not_carry_heavy_things_and_lets_go_of_what_a_cop_grabs() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ToothMouseRig
	rig.mouse.position = ToothMouseRig.ROUTE[4]
	rig._next = 4
	office.main.global_position = office.to_global(ToothMouseRig.ROUTE[4] + Vector3.UP * 0.18)
	await wait_physics_frames(3)
	assert_null(rig.carrying, "the 3 kg jar is too heavy")
	var candy: Grabbable = office.candies[0]
	rig.mouse.position = ToothMouseRig.ROUTE[6]
	rig._next = 7
	candy.global_position = office.to_global(ToothMouseRig.ROUTE[6] + Vector3.UP * 0.05)
	await wait_physics_frames(3)
	assert_eq(rig.carrying, candy)
	office.get_node("Cop/Grabber").grab(candy)
	await wait_physics_frames(2)
	assert_null(rig.carrying, "a cop took it")
	assert_false(candy.freeze)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_TOOTH_MOUSE_B", "BRIEF_TOOTH_MOUSE_C", "BRIEF_TOOTH_MOUSE_D", "OBJ_FIND_TEETH_JAR",
			"OBJ_EXTRA_MOUSE_COSTUME", "OBJ_EXTRA_PILLOW_MAP", "LUCHO_CLUE_tooth_mouse", "CLUE_TALC_PRINTS"]:
		assert_ne(tr(key), key)
