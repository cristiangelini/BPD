extends GutTest

## The politician's rally at the plaza (proteccion-politico.md, step 1, decision 103): the stage with its ramp and
## lectern, deputy Lustre behind it, and his speech, which waits for his guard and then runs for SPEECH_TIME.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=plaza"])), "plaza")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["plaza"]))


func test_the_stage_is_on_the_plaza_and_he_stands_on_it() -> void:
	var plaza := CityLayout.block_center(CityLayout.PLAZA)
	assert_lt(absf(rally.stage_top.x - plaza.x), CityLayout.BLOCK / 2, "on the plaza's block")
	assert_lt(absf(rally.stage_top.z - plaza.z), CityLayout.BLOCK / 2)
	await wait_physics_frames(10)
	assert_almost_eq(rally.politician.global_position.y, rally.stage_top.y, 0.2, "up on the stage")


func test_he_waits_for_his_guard() -> void:
	await wait_physics_frames(5)
	assert_false(rally.speech.speaking, "the cops are at the station, far away")
	assert_eq(rally.speech.left, PoliticianSpeech.SPEECH_TIME)
	assert_eq(rally.politician.said(), "POLITICIAN_WAITING")


func test_the_first_cop_near_him_starts_the_speech() -> void:
	watch_signals(rally.speech)
	rally.get_node("Cop").global_position = rally.stage_top + Vector3(0, -1, 8)
	await wait_physics_frames(3)
	assert_true(rally.speech.speaking)
	assert_signal_emitted(rally.speech, "started")
	assert_string_starts_with(rally.politician.said(), "SPEECH_LUSTRE_")


func test_the_speech_ends_on_its_own() -> void:
	watch_signals(rally.speech)
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)
	assert_true(rally.speech.over)
	assert_signal_emitted(rally.speech, "finished")
	assert_eq(rally.politician.said(), "SPEECH_LUSTRE_END")


func test_the_same_seed_gives_the_same_speech() -> void:
	var a := PoliticianSpeech.new()
	var b := PoliticianSpeech.new()
	a.setup(rally.politician, 11)
	b.setup(rally.politician, 11)
	assert_eq(a._order, b._order)
	assert_eq(a._order.size(), PoliticianSpeech.LINES)
	a.free()
	b.free()


func test_every_line_has_its_text() -> void:
	for i in PoliticianSpeech.LINES:
		var key := "SPEECH_LUSTRE_%d" % (i + 1)
		assert_ne(tr(key), key, key)
