extends GutTest

## The Las Palomas building with the smuggling piano's story (docs/diseno/edificio.md, step 7): the grand piano full
## of ingots in 30B's living room, too big for the elevator, its "clonc" as the clue, an ingot loose with every hard
## hit, the sheet music and the loose ingot hidden with the seed, and the piano in the trunk solving the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "smuggling_piano"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


func test_the_piano_in_the_living_room() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_has(tower.raid.suspicions, "smuggling_piano")
	var piano := tower.main as ContrabandPiano
	assert_not_null(piano)
	assert_true(ApartmentTower.on_top_floor(tower.to_local(piano.global_position)))
	var size := ((piano.get_node("Shape") as CollisionShape3D).shape as BoxShape3D).size
	assert_gt((size.x + size.z) / sqrt(2.0), TowerElevator.INSIDE.x, "it doesn't fit in the elevator")
	assert_eq(tower.extras.size(), 2, "the sheet music and the loose ingot")
	assert_true(ApartmentTower.SPOTS[tower.hidden_spots[1]].heavy, "the 12 kg ingot in a spot it fits")
	await wait_seconds(1.0)
	assert_eq(piano.value, piano.full_value, "it settles without a scratch")


func test_clonc_is_the_clue() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var piano := tower.main as ContrabandPiano
	var cop: Cop = tower.get_node("Cop")
	assert_eq(piano.prompt_key(cop), "PROMPT_PIANO")
	piano.use(cop)
	assert_has(tower.raid.clues_found, tr("CLUE_PIANO_CLONK"))
	var clues: int = tower.raid.clues_found.size()
	piano.use(cop)
	assert_eq(tower.raid.clues_found.size(), clues, "the clue only once")


func test_every_hard_hit_shakes_an_ingot_loose() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var piano := tower.main as ContrabandPiano
	watch_signals(piano)
	piano.hit(2.0)
	assert_signal_emit_count(piano, "ingot_dropped", 1)
	piano.hit(1.0)
	assert_signal_emit_count(piano, "ingot_dropped", 1, "a soft knock does nothing")
	for i in 4:
		piano.hit(2.0)
	assert_signal_emit_count(piano, "ingot_dropped", ContrabandPiano.INGOTS, "only so many inside")
	var ingot: RigidBody3D = get_signal_parameters(piano, "ingot_dropped", 0)[0]
	assert_almost_eq(ingot.mass, 12.0, 0.01)


func test_the_piano_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var piano := tower.main
	piano.global_position = tower.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(piano))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("smuggling_piano")))
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_SMUGGLING_PIANO_B", "BRIEF_SMUGGLING_PIANO_C", "BRIEF_SMUGGLING_PIANO_D",
			"OBJ_FIND_SMUGGLING_PIANO", "OBJ_EXTRA_PIANO_SHEET", "OBJ_EXTRA_GOLD_INGOT", "PEPA_TIP_smuggling_piano",
			"PROMPT_PIANO", "HINT_PIANO_CLONK", "CLUE_PIANO_CLONK"]:
		assert_ne(tr(key), key)
