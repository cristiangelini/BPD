extends GutTest

## The sabotage (politico-debate.md, step 4, decision 230): the warning light, the 4 tricks, how the cops undo each one,
## and the blunder when they don't in time.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio
var sabotage: TvSabotage
var debate: TvDebate


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	var cop := studio.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)
	sabotage = studio.sabotage
	debate = studio.debate
	debate.start()


func _head() -> Vector3:
	return studio.politician.global_position + Vector3.UP * 1.3


func test_a_trick_is_warned_then_pulled() -> void:
	watch_signals(sabotage)
	sabotage.left = 0.01
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.WARN)
	assert_true(studio.warning.visible, "the yellow light on the console")
	assert_signal_emitted(sabotage, "warned")
	sabotage.left = 0.01
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.ON)
	assert_signal_emitted(sabotage, "started")


func test_not_fixed_in_time_is_a_blunder_on_air() -> void:
	sabotage.warn("light")
	sabotage.pull()
	assert_false(studio.spot_on(TvSabotage.LUSTRE_SPOT), "his spot goes out")
	var image := debate.image
	sabotage.left = 0.01
	await wait_physics_frames(2)
	assert_eq(debate.blunders, 1)
	assert_eq(debate.image, image - TvDebate.BLUNDER)
	assert_true(studio.spot_on(TvSabotage.LUSTRE_SPOT), "the control room turns it back on after")
	assert_false(studio.warning.visible)


func test_a_card_held_near_him_beats_the_teleprompter() -> void:
	sabotage.warn("teleprompter")
	sabotage.pull()
	assert_string_starts_with(studio.prompter.text(), "TV_PROMPTER_BAD_")
	assert_false(sabotage.is_fixed(), "a card on the table doesn't help")
	var card := studio.props[0]
	card.hold(1000, _head() + Vector3(0, 0, 1.5))
	await wait_physics_frames(20)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE, "fixed")
	assert_eq(debate.blunders, 0)
	assert_eq(studio.prompter.text(), "TV_PROMPTER_OK")
	card.let_go(1000)


func test_unplugging_the_teleprompter_beats_it_for_good_but_he_improvises() -> void:
	sabotage.warn("teleprompter")
	sabotage.pull()
	studio.prompter.use(studio.get_node("Cop"))
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE)
	for i in 20:
		assert_ne(sabotage.call("_pick"), "teleprompter", "never again")
	debate.left = TvDebate.BLOCK - TvDebate.ASK - 1.0
	await wait_physics_frames(1)
	var image := debate.image
	debate.left = TvDebate.BLOCK - TvDebate.ASK - TvDebate.ANSWER - 1.0
	await wait_physics_frames(1)
	assert_eq(debate.image, image + TvDebate.ANSWER_GAIN / 2 - TvDebate.MALVON_GAIN, "half as good without it")


func test_his_camera_aimed_back_at_him() -> void:
	sabotage.warn("camera")
	sabotage.pull()
	var camera := studio.cameras[TvSabotage.LUSTRE_CAMERA]
	assert_false(camera.frames(_head()), "it looks away")
	camera.aim_at(studio.politician.global_position)
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE)
	assert_eq(debate.blunders, 0)


func test_the_switch_on_the_console_turns_his_spot_back_on() -> void:
	sabotage.warn("light")
	sabotage.pull()
	studio.light_switch.use(studio.get_node("Cop"))
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE)
	assert_true(studio.spot_on(TvSabotage.LUSTRE_SPOT))


func test_a_flashlight_on_him_lights_him_too() -> void:
	sabotage.warn("light")
	sabotage.pull()
	var cop := studio.get_node("Cop") as Cop
	var at := studio.politician.global_position + Vector3(0, 0.1, 4.0)
	cop.global_transform = Transform3D(Basis.looking_at(Vector3(0, 0, -1)), at)
	await wait_physics_frames(2)
	cop.belt.flashlight.toggle()
	await wait_physics_frames(3)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE, "his flashlight on the deputy")


func test_the_spare_mic_brought_to_him_and_back_to_its_table() -> void:
	sabotage.warn("mic")
	sabotage.pull()
	assert_string_starts_with(studio.politician.said(), "TV_MIC_NOISE_")
	var mic := studio.spare_mic
	mic.global_position = _head() + Vector3(0, 0, 0.8)
	await wait_physics_frames(2)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE)
	assert_lt(mic.global_position.distance_to(studio.to_global(TvStudio.MIC_AT)), 0.3, "back on the makeup table")


func test_no_tricks_in_the_ad_break() -> void:
	debate.left = 0.01
	await wait_physics_frames(2)
	assert_eq(debate.state, TvDebate.State.BREAK)
	sabotage.left = 0.01
	await wait_physics_frames(5)
	assert_eq(sabotage.phase, TvSabotage.Phase.NONE)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["TV_PROMPTER_OK", "PROMPT_UNPLUG_PROMPTER", "PROMPT_PLUG_PROMPTER", "PROMPT_SPOTS_ON",
		"HINT_SABOTAGE_FIXED"]
	for kind in TvSabotage.KINDS:
		keys.append("HINT_SABOTAGE_%s" % kind.to_upper())
	for i in TvSabotage.BAD_LINES:
		keys.append("TV_PROMPTER_BAD_%d" % (i + 1))
	for i in TvSabotage.NOISES:
		keys.append("TV_MIC_NOISE_%d" % (i + 1))
	for i in TvStudio.CARDS:
		keys.append("TV_CARD_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
