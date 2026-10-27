extends GutTest

## The dental office raid with the rising chair story (allanamiento-dentista.md, step 6): the loot bag in the false
## ceiling over chair 2, the pedal that lifts the chair with the cop on it, the hatch only reached from up there, its
## extras hidden with the seed and the shoe prints on the backrest as the story's clue.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "rising_chair"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_bag_waits_in_the_ceiling_and_the_extras_are_hidden() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_has(office.raid.suspicions, "rising_chair")
	assert_true(office.rig is RisingChairRig)
	assert_eq(office.raid.main_evidence, office.main)
	assert_false(office.main.visible, "up in the false ceiling")
	assert_true(office.main.freeze)
	assert_gt(office.main.position.y, DentistRaid.WALL_TOP)
	assert_eq(office.extras.size(), 2, "the key and the plan")
	assert_eq(office.hidden.size(), 2)


func test_the_hatch_is_out_of_reach_from_the_floor() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as RisingChairRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(DentistRaid.CHAIRS[1] + Vector3(0, 0.1, 0.9))
	rig.hatch_button.use(cop)
	assert_false(rig.opened)


func test_the_pedal_lifts_the_cop_on_the_chair_to_the_hatch() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as RisingChairRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(DentistRaid.CHAIRS[1] + Vector3(0, 1.1, -0.3))
	for i in 30:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	var standing := cop.global_position.y
	rig.pedal.use(cop)
	assert_true(rig.raised)
	for i in int((RisingChairRig.LIFT / RisingChairRig.LIFT_SPEED + 0.5) * 60):
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_true(rig.is_up())
	for i in 30:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.y, standing + RisingChairRig.LIFT * 0.8, "it rides up on the chair")
	rig.hatch_button.use(cop)
	assert_true(rig.opened)
	assert_true(office.main.visible)
	assert_false(office.main.freeze, "the bag drops")
	assert_eq(rig.net_state(), [true, true])


func test_the_pedal_takes_it_down_again() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as RisingChairRig
	rig.apply_net_state([true, false])
	await wait_seconds(RisingChairRig.LIFT / RisingChairRig.LIFT_SPEED + 0.3)
	assert_true(rig.is_up())
	rig.toggle()
	await wait_seconds(RisingChairRig.LIFT / RisingChairRig.LIFT_SPEED + 0.3)
	assert_almost_eq(rig.lift.position.y, DentistRaid.CHAIRS[1].y, 0.01)


func test_the_shoe_prints_are_a_clue_the_first_time_close() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as RisingChairRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(DentistRaid.CHAIRS[1] + Vector3(0.8, 0.1, 0.6))
	await wait_physics_frames(2)
	assert_true(rig.saw_marks)
	assert_has(office.raid.clues_found, tr("CLUE_CHAIR_MARKS"))


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_RISING_CHAIR_B", "BRIEF_RISING_CHAIR_C", "BRIEF_RISING_CHAIR_D", "OBJ_FIND_LOOT_BAG",
			"OBJ_EXTRA_HATCH_KEY", "OBJ_EXTRA_CEILING_PLAN", "LUCHO_CLUE_rising_chair", "CLUE_CHAIR_MARKS",
			"PROMPT_CHAIR_PEDAL", "PROMPT_CEILING_HATCH", "HINT_HATCH_TOO_HIGH"]:
		assert_ne(tr(key), key)
