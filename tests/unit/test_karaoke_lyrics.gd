extends GutTest

## The karaoke's lyrics with messages story (allanamiento-karaoke.md, step 6): the lyrics computer and its extras
## hidden with the seed, the lines on the screen while a customer sings, the message that doesn't belong in any song,
## read by a cop looking at the screen (the clue, once), and the broken screen that shows nothing.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_lyrics"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


## The cop in the room, `facing` the screen or with their back to it.
func _cop(place: Karaoke, facing: bool) -> Cop:
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Vector3(-2.0, Karaoke.FLOOR_TOP + 0.05, -2.0))
	cop.global_rotation.y = place.global_rotation.y + (0.0 if facing else PI)
	return cop


func test_the_lyrics_computer_and_its_extras_are_hidden() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_has(place.raid.suspicions, "karaoke_lyrics")
	assert_eq(place.main, place.hidden[0])
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the notebook and the receipt")
	assert_true(Karaoke.SPOTS[place.hidden_spots[0]].heavy, "the computer is big")


func test_the_screen_shows_lines_while_a_customer_sings() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: LyricsRig = place.rig
	assert_eq(rig.showing, "")
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	await wait_physics_frames(2)
	assert_has(LyricsRig.LYRICS, rig.showing, "a line of the song")


func test_a_message_read_by_a_cop_looking_at_the_screen_is_the_clue_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: LyricsRig = place.rig
	_cop(place, false)
	await wait_physics_frames(2)
	for i in LyricsRig.CODE_EVERY:
		rig.next_line()
	assert_has(LyricsRig.CODES, rig.showing, "a line from no song")
	assert_false(rig.noticed, "with their back to it")
	_cop(place, true)
	await wait_physics_frames(2)
	for i in LyricsRig.CODE_EVERY:
		rig.next_line()
	assert_true(rig.noticed)
	assert_has(place.raid.clues_found, tr("KARAOKE_LYRICS_CLUE"))
	var clues: int = place.raid.clues_found.size()
	for i in LyricsRig.CODE_EVERY:
		rig.next_line()
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_the_broken_screen_shows_nothing() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: LyricsRig = place.rig
	place.break_screen()
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	await wait_physics_frames(2)
	assert_eq(rig.showing, "")
	assert_false(rig._text.visible)


func test_the_lyrics_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_KARAOKE_LYRICS_B", "BRIEF_KARAOKE_LYRICS_C", "BRIEF_KARAOKE_LYRICS_D",
		"OBJ_FIND_LYRICS_PC", "OBJ_EXTRA_KARAOKE_CODES", "OBJ_EXTRA_GOODS_RECEIPT", "TOTO_CLUE_karaoke_lyrics",
		"KARAOKE_LYRICS_CLUE"]
	keys.append_array(LyricsRig.LYRICS)
	keys.append_array(LyricsRig.CODES)
	for key: String in keys:
		assert_ne(tr(key), key, key)
