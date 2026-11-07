extends GutTest

## The costume shop's theater costumes (allanamiento-disfraces.md, step 6): the theater's trunk is hidden with its
## stamp and the play's program, a costume on the jobs rack has the theater's tag (the clue) and the theater's poster
## hangs on the east wall.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "theater_costumes"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_trunk_is_hidden_with_the_extras() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_eq(place.main, place.hidden[0], "the trunk is the main evidence")
	assert_almost_eq(place.main.mass, 15.0, 0.01)
	assert_true(CostumeShop.SPOTS[place.hidden_spots[0]].heavy)
	assert_eq(place.extras.size(), 2, "the stamp and the program")


func test_the_tag_on_the_jobs_rack_is_the_clue() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var rig := place.rig as TheaterCostumesRig
	var rack: Vector3 = CostumeShop.RACKS[4]
	assert_lt(absf(rig.tag.position.x - rack.x), CostumeShop.RACK_SIZE.x / 2, "on the jobs rack")
	assert_almost_eq(rig.tag.position.z, rack.z, 0.01)
	var cop: Cop = place.get_node("Cop")
	assert_eq(rig.tag.prompt_key(cop), "PROMPT_COSTUME_TAG")
	rig.tag.use(cop)
	assert_true(place.raid.clues_found.has(tr("CLUE_THEATER_TAG")))
	for key: String in ["BRIEF_THEATER_B", "BRIEF_THEATER_C", "BRIEF_THEATER_D", "OBJ_FIND_THEATER",
			"OBJ_EXTRA_THEATER_STAMP", "OBJ_EXTRA_PLAY_PROGRAM", "PROMPT_COSTUME_TAG", "CLUE_THEATER_TAG", "THEATER_POSTER",
			"MIMI_CLUE_theater_costumes"]:
		assert_ne(tr(key), key, key)
