extends GutTest

## The karaoke's tuning microphone story (allanamiento-karaoke.md, step 6): the golden microphone and its extras
## hidden with the seed, the booth microphone that makes a cop sing perfectly (the clue, once) and Rosaura off key in a
## duet.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_tuner"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_golden_microphone_and_its_extras_are_hidden() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_has(place.raid.suspicions, "karaoke_tuner")
	assert_eq(place.main, place.hidden[0])
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the chip and the manual")


func test_a_cop_with_the_tuned_booth_microphone_sings_perfectly_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: TunerRig = place.rig
	assert_gte(rig.tuned, 2, "one of the booths'")
	var other := place.mics[1]
	var cop: Cop = place.get_node("Cop")
	var grabber := cop.get_node("Grabber")
	other.hold(grabber.get_instance_id(), other.global_position + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_false(rig.noticed, "another microphone is just a microphone")
	other.let_go(grabber.get_instance_id())
	var mic := place.mics[rig.tuned]
	mic.hold(grabber.get_instance_id(), mic.global_position + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_true(rig.noticed)
	assert_true(rig._notes.visible, "golden notes")
	assert_has(place.raid.clues_found, tr("KARAOKE_TUNER_CLUE"))
	var clues: int = place.raid.clues_found.size()
	mic.let_go(grabber.get_instance_id())
	await wait_physics_frames(2)
	assert_false(rig._notes.visible)
	mic.hold(grabber.get_instance_id(), mic.global_position + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_rosaura_is_off_key_in_a_duet() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var boss := place.owner_boss
	boss.start_at(5)
	boss.fix_time = 6.0
	place.duet_call.duet()
	await wait_until(func() -> bool: return boss.is_fixing(), 8.0)
	await wait_physics_frames(3)
	var squeals := place.find_children("*", "Label3D", false, false).filter(
		func(label: Label3D) -> bool: return label.text == "DIVA_OFF_KEY")
	assert_eq(squeals.size(), 1, "she squeals")


func test_the_tuner_texts_exist() -> void:
	for key: String in ["BRIEF_KARAOKE_TUNER_B", "BRIEF_KARAOKE_TUNER_C", "BRIEF_KARAOKE_TUNER_D",
			"OBJ_FIND_GOLDEN_MIC", "OBJ_EXTRA_TUNER_CHIP", "OBJ_EXTRA_DIVA_MANUAL", "TOTO_CLUE_karaoke_tuner",
			"KARAOKE_TUNER_SING", "KARAOKE_TUNER_CLUE", "DIVA_OFF_KEY"]:
		assert_ne(tr(key), key, key)
