extends GutTest

## Pipo and the shoes at the bowling alley (allanamiento-bolera.md, step 4): he stands behind the counter, E gives a
## cop a pair of shoes and E again gives them back, and the first pair back from each cop gets what he saw; with the
## shoes on a cop slides less on the waxed lanes.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley() -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_pipo_is_behind_the_counter_within_reach() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var pipo := alley.pipo
	assert_not_null(pipo)
	assert_gt(pipo.position.z, Bowling.COUNTER_AT.z, "behind the counter")
	# The models face +Z.
	assert_lt(pipo.global_basis.z.dot(alley.global_basis * Vector3.BACK), -0.9, "facing the alley")
	var eye := alley.to_global(Vector3(Bowling.PIPO_AT.x, 1.6, Bowling.COUNTER_AT.z - 0.9))
	var chest := pipo.global_position + Vector3.UP * 0.9
	assert_lt(eye.distance_to(chest), GameScale.GRAB_REACH, "close enough")
	var hit := alley.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(eye, chest))
	assert_eq(hit.get("collider"), pipo, "over the counter")


func test_shoes_on_and_back_tell_what_he_saw_once() -> void:
	var alley := _alley()
	var pipo := alley.pipo
	var cop: Cop = alley.get_node("Cop")
	pipo.clue = "the clue"
	pipo.clue_speech = "I saw it"
	watch_signals(pipo)
	assert_eq(pipo.prompt_key(cop), "PROMPT_PIPO_SHOES")
	pipo.use(cop)
	assert_true(pipo.wears(cop))
	assert_eq(pipo.prompt_key(cop), "PROMPT_PIPO_RETURN")
	assert_signal_not_emitted(pipo, "told")
	pipo.use(cop)
	assert_false(pipo.wears(cop))
	assert_signal_emitted_with_parameters(pipo, "told", ["the clue"])
	assert_eq(pipo.said(), "I saw it")
	pipo.use(cop)
	pipo.use(cop)
	assert_signal_emit_count(pipo, "told", 1)
	assert_eq(pipo.said(), "PIPO_THANKS", "once per cop")


func test_without_a_clue_he_saw_nothing() -> void:
	var alley := _alley()
	var cop: Cop = alley.get_node("Cop")
	alley.pipo.clue = ""
	alley.pipo.clue_speech = ""
	alley.pipo.use(cop)
	alley.pipo.use(cop)
	assert_eq(alley.pipo.said(), "PIPO_NOTHING")
	assert_false(alley.pipo.has_told)


func test_with_the_shoes_on_a_cop_slides_less() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	cop.global_position = alley.to_global(Vector3(Bowling.LANE_X[3], 0.2, 0.0))
	cop.is_running = true
	cop.velocity = alley.global_basis * Vector3(0, 0, -5.0)
	alley._skate(0.1)
	assert_almost_eq(cop._knock.length(), Bowling.SKATE_PUSH, 0.01, "barefoot, the full slide")
	alley._skated.clear()
	alley.pipo.use(cop)
	cop.velocity = alley.global_basis * Vector3(0, 0, -5.0)
	alley._skate(0.1)
	assert_almost_eq(cop._knock.length(), Bowling.SHOD_PUSH, 0.01, "with shoes, a little")
	for key: String in ["PROMPT_PIPO_SHOES", "PROMPT_PIPO_RETURN", "PIPO_SHOES", "PIPO_THANKS", "PIPO_NOTHING",
			"PIPO_IDLE_1", "PIPO_IDLE_3", "HINT_BOWL_SHOES_ON", "HINT_BOWL_SHOES_OFF"]:
		assert_ne(tr(key), key, key)
