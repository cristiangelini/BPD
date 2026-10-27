extends GutTest

## The cinema's watches in the popcorn (allanamiento-cine.md, step 6): the bucket full of watches hidden with its
## extras, the metal popcorn on the counter that ticks (the clue, once), and the machine popping a watch every 15 s.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "popcorn_watches"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_the_bucket_is_hidden_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_has(cinema.raid.suspicions, "popcorn_watches")
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 4.0, 0.01)
	assert_eq(cinema.extras.size(), 2, "the scale and the list")


func test_the_ticking_popcorn_is_a_clue_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as PopcornWatchesRig
	assert_gt(rig.ticking.position.y, Cinema.CANDY_AT.y + Cinema.CANDY_SIZE.y, "on the counter")
	var cop: Cop = cinema.get_node("Cop")
	assert_eq(rig.ticking.prompt_key(cop), "PROMPT_TICKING_POPCORN")
	rig.ticking.use(cop)
	assert_has(cinema.raid.clues_found, tr("CLUE_TICKING_POPCORN"))
	var clues: int = cinema.raid.clues_found.size()
	rig.ticking.use(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")


func test_the_machine_pops_a_watch_until_its_glass_breaks() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as PopcornWatchesRig
	rig._until_pop = 0.1
	await wait_seconds(0.5)
	assert_eq(rig.pops, 1)
	assert_true(rig._watch.visible)
	assert_gt(rig._watch.position.y, Cinema.POPCORN_AT.y + Cinema.POPCORN_SIZE.y, "over the machine")
	await wait_seconds(PopcornWatchesRig.POP_SECONDS)
	assert_false(rig._watch.visible)
	cinema.break_glass()
	rig._until_pop = 0.1
	await wait_seconds(0.5)
	assert_eq(rig.pops, 1, "no machine, no watches")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_POPCORN_WATCHES_B", "BRIEF_POPCORN_WATCHES_C", "BRIEF_POPCORN_WATCHES_D",
			"OBJ_FIND_WATCHES_BUCKET", "OBJ_EXTRA_BOOTH_SCALE", "OBJ_EXTRA_CLIENT_LIST", "CHICHO_CLUE_popcorn_watches",
			"PROMPT_TICKING_POPCORN", "HINT_TICKING_POPCORN", "CLUE_TICKING_POPCORN", "CINEMA_TICK_TACK",
			"CINEMA_WATCH_POP"]:
		assert_ne(tr(key), key)
