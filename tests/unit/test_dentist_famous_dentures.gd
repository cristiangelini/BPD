extends GutTest

## The dental office raid with the famous dentures story (allanamiento-dentista.md, step 6): the briefcase of copies
## and its extras, the chattering denture on the desk as the story's clue, and the wind-up dentures that walk the front
## of the office and bite the shoes of the cops they reach.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "famous_dentures"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_briefcase_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_has(office.raid.suspicions, "famous_dentures")
	assert_eq(office.main, office.hidden[0])
	assert_almost_eq((office.main as RigidBody3D).mass, 4.0, 0.01)
	assert_eq(office.extras.size(), 2, "the photo and the half mold")
	assert_true(office.rig is FamousDenturesRig)


func test_the_desk_denture_clacks_and_the_first_time_close_is_a_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as FamousDenturesRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(FamousDenturesRig.DESK_TEETH + Vector3(0, -0.7, 1.2))
	await wait_physics_frames(2)
	assert_true(rig.heard_clacks)
	assert_has(office.raid.clues_found, tr("CLUE_DESK_CHATTER"))


func test_the_dentures_walk_inside_the_front_of_the_office() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as FamousDenturesRig
	assert_eq(rig.walkers.size(), FamousDenturesRig.WALKERS)
	var before: Array = rig.net_state()
	await wait_seconds(0.5)
	assert_ne(rig.net_state(), before, "they walk")
	for walker: Node3D in rig.walkers:
		assert_true(FamousDenturesRig.AREA.grow(0.1).has_point(Vector2(walker.position.x, walker.position.z)))


func test_a_bitten_cop_walks_slowly_for_a_while() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as FamousDenturesRig
	var cop: Cop = office.get_node("Cop")
	var walker := rig.walkers[0]
	cop.global_position = office.to_global(walker.position + Vector3(0.1, 0.1, 0))
	await wait_physics_frames(2)
	assert_eq(rig.bites, 1)
	assert_true(rig.is_slowed(cop))
	assert_eq(cop.slow_factor, FamousDenturesRig.BITE_SLOW)
	await wait_physics_frames(2)
	assert_eq(rig.bites, 1, "not again right away")
	rig._slow[cop] = 0.01
	await wait_physics_frames(2)
	assert_false(rig.is_slowed(cop))
	assert_eq(cop.slow_factor, 1.0, "back to normal")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FAMOUS_DENTURES_B", "BRIEF_FAMOUS_DENTURES_C", "BRIEF_FAMOUS_DENTURES_D",
			"OBJ_FIND_DENTURES_CASE", "OBJ_EXTRA_SMILE_PHOTO", "OBJ_EXTRA_HALF_MOLD", "LUCHO_CLUE_famous_dentures",
			"CLUE_DESK_CHATTER", "DESK_CLACK", "HINT_DENTURE_BITE"]:
		assert_ne(tr(key), key)
