extends GutTest

## The rink raid with the smuggling resurfacer (allanamiento-pista.md, step 6): the box of stolen perfumes in the
## patrol car's trunk solves the case; the running resurfacer leaves a pink trail on the ice, the first smear a clue,
## and drops a bottle of perfume once every lap, at most six.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "resurfacer_smuggling"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_perfume_box_solves_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "resurfacer_smuggling")
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_perfume_box.tscn")
	assert_eq(rink.main.mass, 6.0)
	assert_true(Rink.SPOTS[rink.hidden_spots[0]].heavy, "the box only fits in a big spot")
	assert_eq(rink.extras.size(), 2, "the client list and the funnel")
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("resurfacer_smuggling")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_the_running_resurfacer_leaves_a_pink_trail_and_the_first_smear_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as ResurfacerSmugglingRig
	await wait_seconds(1.0)
	assert_eq(rig.smears.size(), 0, "parked, no trail")
	rink.resurfacer.start()
	await wait_seconds(2.0)
	assert_between(rig.smears.size(), 3, 5, "a smear every half second")
	assert_eq(rink.raid.clues_found.count(tr("CLUE_PINK_TRAIL")), 1, "one clue")
	for smear in rig.smears:
		assert_true(Rink.on_ice(smear.position), "the trail is on the ice")


func test_a_bottle_falls_once_every_lap_at_most_six() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as ResurfacerSmugglingRig
	rink.resurfacer.start()
	rink.resurfacer.along = ResurfacerSmugglingRig.BOTTLE_AT - 0.5
	await wait_seconds(0.5)
	assert_eq(rig.bottles.size(), 1, "one bottle into the lap")
	await wait_seconds(1.0)
	assert_eq(rig.bottles.size(), 1, "and no more that lap")
	assert_true(rig.bottles[0] is Grabbable, "it can be picked up")
	for i in 10:
		rink.resurfacer.along += IceResurfacer.loop_length()
		await wait_physics_frames(2)
	assert_eq(rig.bottles.size(), ResurfacerSmugglingRig.MAX_BOTTLES)


func test_copito_tells_where_she_hid_something() -> void:
	var rink := _rink(6)
	await wait_physics_frames(2)
	assert_string_contains(rink.copito.clue_speech, tr("LOC_" + Rink.SPOTS[rink.hidden_spots[6 % 3]].id))


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_RESURFACER_SMUGGLING_B", "BRIEF_RESURFACER_SMUGGLING_C", "BRIEF_RESURFACER_SMUGGLING_D",
			"OBJ_FIND_PERFUME_BOX", "OBJ_EXTRA_CLIENT_LIST", "OBJ_EXTRA_FUNNEL", "COPITO_CLUE_resurfacer_smuggling",
			"CLUE_PINK_TRAIL", "RINK_PERFUME_DROP"]:
		assert_ne(tr(key), key, key)
