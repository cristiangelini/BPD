extends GutTest

## The doll factory's spy dolls (docs/diseno/fabrica.md, step 6): ten dolls of the bin carry a microphone, drawn with
## the seed; a cop's radio squeals by the closest one (the story's clue, once), and the tape recorder in the trunk solves it.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "spy_dolls"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_ten_dolls_carry_a_microphone() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as SpyDollsRig
	assert_eq(rig.mic_dolls.size(), SpyDollsRig.MIC_DOLLS)
	for doll: Node3D in rig.mic_dolls:
		assert_has(factory.pile, doll)
		assert_true(doll.has_node("SpyMic"))
	assert_eq(SpyDollsRig.pick(5, 24), SpyDollsRig.pick(5, 24), "same seed, same dolls")
	assert_ne(SpyDollsRig.pick(5, 24), SpyDollsRig.pick(6, 24), "another seed, other dolls")
	assert_true(factory.main is Evidence and factory.main.mass >= 6.0, "the tape recorder is the main evidence")
	assert_eq(factory.extras.size(), 2, "the microphones and the list")


func test_the_radio_squeals_close_up_and_tells_once() -> void:
	var factory := _factory()
	var cop: Cop = factory.get_node("Cop")
	await wait_physics_frames(5)
	var rig := factory.rig as SpyDollsRig
	assert_false(rig.was_heard, "the cop is by the car")
	var doll := rig.mic_dolls[0]
	cop.global_position = doll.global_position + Vector3(0, 0, 1.2)
	await wait_physics_frames(3)
	assert_true(rig.was_heard)
	var squealing := rig.mic_dolls.filter(func(d: Node3D) -> bool: return (d.get_node("Squeal") as Label3D).visible)
	assert_eq(squealing.size(), 1, "only by the closest doll with a microphone")
	rig.squeal(rig.mic_dolls[1])
	assert_eq(factory.raid.clues_found, [tr("CLUE_SPY_FEEDBACK")] as Array[String], "the clue only once")


func test_the_recorder_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	factory.main.global_position = factory.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(factory.main))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("spy_dolls")))
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_SPY_DOLLS_B", "BRIEF_SPY_DOLLS_C", "BRIEF_SPY_DOLLS_D", "OBJ_FIND_TAPE_RECORDER",
			"OBJ_EXTRA_MIC_BOX", "OBJ_EXTRA_CLIENT_LIST", "NILDA_CLUE_spy_dolls", "CLUE_SPY_FEEDBACK", "SPY_SQUEAL"]:
		assert_ne(tr(key), key)
