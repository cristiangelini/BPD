extends GutTest

## The gym raid's fake record story (allanamiento-gimnasio.md, step 5): the polystyrene "300 kg" bar hangs on the
## record wall as the main evidence until a cop lifts it with one hand (the clue, once), a real 40 kg bar lies by the
## benches, the doctored photo and the certificate are hidden, and the bar in the trunk solves the case.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "fake_record"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_the_bar_hangs_on_the_record_wall_and_the_real_one_lies_by_the_benches() -> void:
	var gym := _gym()
	await wait_physics_frames(10)
	var rig := gym.rig as FakeRecordRig
	assert_eq(gym.main, rig.bar)
	assert_false(gym.record_bar_look.visible, "the look gives way to the real thing")
	assert_almost_eq(gym.to_local(rig.bar.global_position).distance_to(GymRaid.RECORD_BAR_AT), 0.0, 0.01,
		"still on its hooks")
	assert_almost_eq(rig.bar.mass, 2.0, 0.01)
	assert_gt(rig.bar.physics_material_override.bounce, 0.5, "polystyrene bounces")
	assert_almost_eq(rig.real_bar.mass, FakeRecordRig.REAL_BAR_KG, 0.01)
	assert_eq(gym.extras.size(), 2, "the doctored photo and the certificate")
	assert_eq(gym.hidden, gym.extras, "the bar isn't hidden")


func test_lifting_it_is_the_clue_once() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as FakeRecordRig
	var grabber: Grabber = gym.get_node("Cop/Grabber")
	rig.bar.hold(grabber.get_instance_id(), rig.bar.global_position + Vector3(-0.5, 0.3, 0))
	await wait_physics_frames(2)
	assert_true(rig.lifted)
	assert_false(rig.bar.freeze, "off its hooks")
	assert_has(gym.raid.clues_found, tr("CLUE_RECORD_ONE_HAND"))
	var clues: int = gym.raid.clues_found.size()
	rig.bar.let_go(grabber.get_instance_id())
	rig.bar.hold(grabber.get_instance_id(), rig.bar.global_position)
	await wait_physics_frames(2)
	assert_eq(gym.raid.clues_found.size(), clues, "only the first time")


func test_the_bar_in_the_trunk_solves_the_case() -> void:
	var gym := _gym()
	await wait_physics_frames(10)
	var bar := gym.main
	bar.freeze = false
	bar.global_transform = gym.car.global_transform.translated_local(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(gym.car.is_delivered(bar))
	assert_true(gym.raid.mark(gym.raid.suspicions.find("fake_record")))
	gym.car.enter(gym.get_node("Cop"))
	assert_true(gym.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_FAKE_RECORD_B", "BRIEF_FAKE_RECORD_C", "BRIEF_FAKE_RECORD_D", "OBJ_FIND_RECORD_BAR",
			"OBJ_EXTRA_RECORD_PHOTO", "OBJ_EXTRA_RECORD_CERTIFICATE", "LULA_CLUE_fake_record", "CLUE_RECORD_ONE_HAND",
			"GYM_RECORD_LIGHT"]:
		assert_ne(tr(key), key)
