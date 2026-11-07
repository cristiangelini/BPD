extends GutTest

## The cinema's floor popcorn story (allanamiento-cine.md, step 6): the sack of swept popcorn hidden with its extras,
## and the bowl on the candy counter that a cop spits out every time, the clue only the first time.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "floor_popcorn"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_the_sack_is_hidden_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_has(cinema.raid.suspicions, "floor_popcorn")
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 6.0, 0.01)
	assert_true(Cinema.SPOTS[cinema.hidden_spots[0]].heavy, "the sack in a spot it fits")
	assert_eq(cinema.extras.size(), 2, "the broom and the sign")


func test_the_counter_popcorn_is_spat_out_and_a_clue_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as FloorPopcornRig
	var top := Cinema.CANDY_AT.y + Cinema.CANDY_SIZE.y
	assert_gt(rig.bowl.position.y, top, "on the counter")
	assert_lt(absf(rig.bowl.position.x - Cinema.CANDY_AT.x), Cinema.CANDY_SIZE.x / 2)
	var cop: Cop = cinema.get_node("Cop")
	assert_eq(rig.bowl.prompt_key(cop), "PROMPT_EAT_POPCORN")
	watch_signals(rig.bowl)
	rig.bowl.use(cop)
	assert_has(cinema.raid.clues_found, tr("CLUE_FLOOR_POPCORN"))
	var clues: int = cinema.raid.clues_found.size()
	rig.bowl.use(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")
	assert_signal_emit_count(rig.bowl, "eaten", 2, "spat out every time")
	var spit := cinema.get_children().filter(func(child: Node) -> bool:
		return child is Label3D and child.text == "CINEMA_SPIT")
	assert_eq(spit.size(), 2)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var cinema := _cinema()
	await wait_physics_frames(10)
	cinema.main.global_position = cinema.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(cinema.car.is_delivered(cinema.main))
	assert_true(cinema.raid.mark(cinema.raid.suspicions.find("floor_popcorn")))
	cinema.car.enter(cinema.get_node("Cop"))
	assert_true(cinema.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FLOOR_POPCORN_B", "BRIEF_FLOOR_POPCORN_C", "BRIEF_FLOOR_POPCORN_D", "OBJ_FIND_POPCORN_BAG",
			"OBJ_EXTRA_RECYCLE_BROOM", "OBJ_EXTRA_FRESH_SIGN", "CHICHO_CLUE_floor_popcorn", "PROMPT_EAT_POPCORN",
			"HINT_FLOOR_POPCORN", "CLUE_FLOOR_POPCORN", "CINEMA_SPIT"]:
		assert_ne(tr(key), key)
