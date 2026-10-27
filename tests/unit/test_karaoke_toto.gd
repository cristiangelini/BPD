extends GutTest

## Toto at the karaoke (allanamiento-karaoke.md, step 4): with his headphones on he hears nothing, the console turns
## the music down for a while, and then he tells each cop once what he saw (the clue only the first time) while every
## customer complains once.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke() -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_with_the_music_on_toto_hears_nothing() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	place.toto.clue = "CLUE"
	place.toto.clue_speech = "SPEECH"
	watch_signals(place.toto)
	place.toto.use(cop)
	assert_eq(place.toto.said(), "TOTO_DEAF_1")
	assert_signal_not_emitted(place.toto, "told")
	assert_eq(place.toto.prompt_key(cop), "PROMPT_TALK_TOTO")


func test_the_volume_down_makes_him_talk_once_per_cop() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	place.toto.clue = "CLUE"
	place.toto.clue_speech = "SPEECH"
	watch_signals(place.toto)
	assert_eq(place.console.prompt_key(cop), "PROMPT_VOLUME_DOWN")
	place.console.use(cop)
	assert_true(place.console.is_low())
	assert_eq(place.console.prompt_key(cop), "", "already down")
	assert_eq(place.toto.said(), "SPEECH")
	assert_signal_emitted_with_parameters(place.toto, "told", ["CLUE"])
	place.console.low_left = 0.0
	place.console.use(cop)
	assert_eq(place.toto.said(), "TOTO_THANKS", "once per cop")
	assert_signal_emit_count(place.toto, "told", 1)


func test_without_a_story_he_saw_nothing() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	place.console.use(place.get_node("Cop"))
	assert_eq(place.toto.said(), "TOTO_NOTHING")


func test_the_music_comes_back_and_the_customers_complain_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	place.console.use(place.get_node("Cop"))
	for singer in place.singers:
		assert_eq(singer.complaints, 1)
		assert_eq(singer.said(), "KARAOKE_SINGER_QUIET")
	assert_eq(place.owner_boss.complaint, Karaoke.SINGER_COMPLAINT * Karaoke.SINGERS)
	place.console.low_left = 0.5
	await wait_seconds(0.7)
	assert_false(place.console.is_low(), "the music is back")
	for key: String in ["PROMPT_TALK_TOTO", "PROMPT_VOLUME_DOWN", "HINT_KARAOKE_VOLUME", "TOTO_DEAF_2", "TOTO_IDLE_1",
			"TOTO_THANKS", "TOTO_NOTHING", "KARAOKE_SINGER_QUIET"]:
		assert_ne(tr(key), key, key)
