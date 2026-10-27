extends GutTest

## The debate (politico-debate.md, step 3, decision 230): it waits for a cop in the studio, 3 blocks of 2 questions with
## ad breaks between them, turns that alternate with the camera on whoever speaks, and Lustre's image going up with his
## clean answers and down with Malvón's and with each blunder.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio
var debate: TvDebate
var cop: Cop


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	cop = studio.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)
	debate = studio.debate


## Jumps the block's clock to `played` seconds in and lets a frame run.
func _at(played: float) -> void:
	debate.left = TvDebate.BLOCK - played
	await wait_physics_frames(1)


func test_everyone_is_at_their_place_and_it_waits_for_a_cop() -> void:
	assert_lt(studio.politician.position.distance_to(TvStudio.LECTERNS[1]), 1.0, "Lustre at his lectern")
	assert_lt(studio.malvon.position.distance_to(TvStudio.LECTERNS[0]), 1.0, "Malvón at hers")
	assert_eq(studio.moderator.look, "moderadora")
	await wait_physics_frames(10)
	assert_eq(debate.state, TvDebate.State.WAITING)
	cop.global_position = studio.to_global(Vector3(-6, 0.1, 2.5))
	await wait_physics_frames(2)
	assert_eq(debate.state, TvDebate.State.BLOCK)
	assert_eq(debate.speaker, "moderator", "the moderator asks first")
	assert_eq(studio.on_air_index, TvDebate.CAMERA_OF.moderator)
	assert_eq(studio.moderator.said(), "TV_QUESTION_1")


func test_the_turns_alternate_and_the_camera_follows() -> void:
	debate.start()
	await _at(TvDebate.ASK + 1.0)
	assert_eq(debate.speaker, "lustre", "Lustre answers the first question first")
	assert_eq(studio.camera_on_air(), studio.cameras[2])
	assert_string_starts_with(studio.politician.said(), "TV_LUSTRE_ANSWER_1")
	await _at(TvDebate.ASK + TvDebate.ANSWER + 1.0)
	assert_eq(debate.speaker, "malvon")
	assert_eq(studio.camera_on_air(), studio.cameras[0])
	await _at(TvDebate.ASK * 2 + TvDebate.ANSWER * 2 + 1.0)
	assert_eq(debate.question, 1)
	assert_eq(debate.speaker, "malvon", "Malvón first on the second question")


func test_the_image_follows_the_answers_and_the_blunders() -> void:
	debate.start()
	await _at(TvDebate.ASK + 1.0)
	await _at(TvDebate.ASK + TvDebate.ANSWER + 1.0)
	assert_eq(debate.image, TvDebate.IMAGE_START + TvDebate.ANSWER_GAIN - TvDebate.MALVON_GAIN, "his clean answer counts")
	var before := debate.image
	watch_signals(debate)
	await _at(TvDebate.ASK * 2 + TvDebate.ANSWER * 2 + 1.0)
	await _at(TvDebate.ASK * 2 + TvDebate.ANSWER * 3 + 1.0)
	assert_eq(debate.speaker, "lustre")
	debate.blunder("teleprompter")
	assert_signal_emitted_with_parameters(debate, "blundered", ["teleprompter"])
	await _at(TvDebate.BLOCK - 0.5)
	assert_eq(debate.image, before - TvDebate.MALVON_GAIN - TvDebate.BLUNDER, "the blunder costs and the answer earns nothing")
	assert_eq(debate.blunders, 1)


func test_three_blocks_with_breaks_and_then_it_ends() -> void:
	watch_signals(debate)
	debate.start()
	for i in TvDebate.BLOCKS:
		assert_eq(debate.block, i + 1)
		debate.left = 0.01
		await wait_physics_frames(2)
		if i < TvDebate.BLOCKS - 1:
			assert_eq(debate.state, TvDebate.State.BREAK)
			debate.left = 0.01
			await wait_physics_frames(2)
	assert_eq(debate.state, TvDebate.State.OVER)
	assert_signal_emit_count(debate, "ad_break", 2)
	assert_signal_emitted(debate, "finished")


func test_the_image_stays_between_0_and_100() -> void:
	debate.start()
	for i in 20:
		debate.blunder("light")
	assert_eq(debate.image, 0)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HUD_DEBATE_WAITING", "HUD_DEBATE_CLOCK", "HUD_DEBATE_BREAK", "HUD_DEBATE_OVER",
		"HINT_DEBATE_BREAK"]
	for i in TvDebate.QUESTIONS:
		keys.append_array(["TV_QUESTION_%d" % (i + 1), "TV_LUSTRE_ANSWER_%d" % (i + 1), "TV_MALVON_ANSWER_%d" % (i + 1)])
	for key in keys:
		assert_ne(tr(key), key)
