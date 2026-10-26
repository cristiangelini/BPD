extends GutTest

## The hardware store's gnomes with watches (docs/diseno/ferreteria.md, step 6): twelve gnomes in the yard, the boss
## drawn with the seed, its tick close up as the story's clue, the fragile ones as fines and the boss in the trunk.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store(case_seed := 5) -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = "gnomes"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_twelve_gnomes_in_the_yard_and_one_is_the_boss() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as GnomesRig
	assert_eq(rig.gnomes.size(), GnomesRig.GNOME_SPOTS.size() - 1)
	assert_eq(store.main, rig.boss)
	assert_eq(GnomesRig.boss_spot(5), 5)
	assert_almost_eq(rig.boss.position.x, GnomesRig.GNOME_SPOTS[5].x, 0.01)
	assert_ne(GnomesRig.boss_spot(5), GnomesRig.boss_spot(6), "another seed, another gnome")
	for spot: Vector3 in GnomesRig.GNOME_SPOTS:
		assert_between(spot.z, -HardwareStore.HALF_Z, HardwareStore.BACK_Z, "in the yard")
	assert_eq(store.extras.size(), 2, "the list and the glue")
	assert_true(rig.boss.value_hidden)


func test_the_boss_ticks_only_close_up_and_tells_once() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var boss := (store.rig as GnomesRig).boss
	boss.tick()
	assert_false(boss.was_heard, "the cop is far, by the car")
	cop.global_position = boss.global_position + Vector3(0, 0, 1.5)
	boss.tick()
	boss.tick()
	assert_true(boss.was_heard)
	assert_eq(store.raid.clues_found, [tr("CLUE_GNOME_TICK")] as Array[String])


func test_a_broken_gnome_is_a_fine() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var gnome: Ornament = (store.rig as GnomesRig).gnomes[0]
	assert_true(gnome.hit(5.0))
	assert_eq(store.fines, Ornament.FINE)
	assert_eq(store.broken_goods, 1)


func test_the_boss_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var boss := store.main
	boss.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(boss))
	assert_true(store.raid.mark(store.raid.suspicions.find("gnomes")))
	assert_eq(store.raid.objective_facts().extras.size(), 2)
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_GNOMES_B", "BRIEF_GNOMES_C", "BRIEF_GNOMES_D", "OBJ_FIND_GNOME_BOSS",
			"OBJ_EXTRA_WATCH_LIST", "OBJ_EXTRA_GLUE", "COSME_CLUE_gnomes", "CLUE_GNOME_TICK", "HINT_GNOME_BOSS",
			"FX_TICK"]:
		assert_ne(tr(key), key)
