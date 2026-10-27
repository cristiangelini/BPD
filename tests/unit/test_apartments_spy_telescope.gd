extends GutTest

## The Las Palomas building with the spy telescope's story (docs/diseno/edificio.md, step 7): the fragile telescope by
## 30B's living room window, light enough for two and the elevator, the vault's code through it and the tape mark on
## the balcony as clues, the notebook and the binoculars hidden with the seed, and the telescope in the trunk solving
## the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "spy_telescope"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


func test_the_telescope_by_the_window() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_has(tower.raid.suspicions, "spy_telescope")
	var telescope := tower.main as SpyTelescope
	assert_not_null(telescope)
	assert_true(ApartmentTower.on_top_floor(tower.to_local(telescope.global_position)))
	assert_almost_eq(telescope.mass, 35.0, 0.01)
	assert_lt(telescope.safe_speed, 2.0, "fragile")
	var size := ((telescope.get_node("Shape") as CollisionShape3D).shape as BoxShape3D).size
	assert_lt(maxf(size.x, size.z), TowerElevator.INSIDE.x, "it fits in the elevator")
	assert_eq(tower.extras.size(), 2, "the notebook and the binoculars")
	await wait_seconds(1.0)
	assert_eq(telescope.value, telescope.full_value, "it settles without a scratch")


func test_the_vault_through_the_telescope_is_a_clue() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var telescope := tower.main as SpyTelescope
	var cop: Cop = tower.get_node("Cop")
	assert_eq(telescope.prompt_key(cop), "PROMPT_TELESCOPE")
	telescope.use(cop)
	assert_has(tower.raid.clues_found, tr("CLUE_TELESCOPE_VAULT"))
	var clues: int = tower.raid.clues_found.size()
	telescope.use(cop)
	assert_eq(tower.raid.clues_found.size(), clues, "the clue only once")


func test_the_tape_mark_on_the_balcony() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var tape: ClueSpot = (tower.rig as SpyTelescopeRig).tape
	var at := tower.to_local(tape.global_position)
	assert_true(ApartmentTower.on_top_floor(at))
	assert_gt(at.z, ApartmentTower.HALF_Z, "out on the balcony")
	tape.use(tower.get_node("Cop"))
	assert_has(tower.raid.clues_found, tr("CLUE_TAPE_MARK"))


func test_the_telescope_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var telescope := tower.main
	telescope.global_position = tower.car.to_global(Vector3(0, 1.0, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(telescope))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("spy_telescope")))
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_SPY_TELESCOPE_B", "BRIEF_SPY_TELESCOPE_C", "BRIEF_SPY_TELESCOPE_D",
			"OBJ_FIND_SPY_TELESCOPE", "OBJ_EXTRA_CODE_NOTEBOOK", "OBJ_EXTRA_BINOCULARS", "PEPA_TIP_spy_telescope",
			"PROMPT_TELESCOPE", "HINT_TELESCOPE_VAULT", "CLUE_TELESCOPE_VAULT", "PROMPT_TAPE_MARK", "CLUE_TAPE_MARK"]:
		assert_ne(tr(key), key)
