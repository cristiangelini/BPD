extends GutTest

## The hardware store's golden screws (docs/diseno/ferreteria.md, step 6): the 60 drawers of the screw wall, the golden
## one drawn with the seed, the jammed ones that spill screws, the glint under the flashlight and the drawer in the trunk.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store(case_seed := 5) -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = "gold_screws"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_sixty_drawers_and_the_golden_one_waits_inside() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as GoldScrewsRig
	assert_eq(rig.drawers.size(), HardwareStore.SCREW_ROWS * HardwareStore.SCREW_COLUMNS)
	assert_eq(rig.gold_index, GoldScrewsRig.gold_drawer(5))
	assert_ne(GoldScrewsRig.gold_drawer(5), GoldScrewsRig.gold_drawer(6), "another seed, another drawer")
	assert_eq(store.main, rig.gold)
	assert_false(rig.gold.visible)
	assert_true(rig.gold.freeze)
	assert_eq(store.extras.size(), 2, "the mold and the bag")
	assert_eq(rig.drawers[0].prompt_key(store.get_node("Cop")), "PROMPT_SCREW_DRAWER")


func test_opening_the_golden_drawer_gives_up_the_evidence() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var rig := store.rig as GoldScrewsRig
	rig.drawers[rig.gold_index].use(cop)
	assert_true(rig.gold.visible)
	assert_false(rig.gold.freeze)
	assert_gt(rig.gold.position.x, rig.drawers[rig.gold_index].position.x, "out in front of the wall")
	assert_eq(rig.drawers[rig.gold_index].prompt_key(cop), "", "it opens once")


func test_a_jammed_drawer_spills_screws_that_trip_a_running_cop() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var rig := store.rig as GoldScrewsRig
	var jammed := range(rig.drawers.size()).filter(func(i: int) -> bool: return rig.spills_at(i))
	var plain := range(rig.drawers.size()).filter(func(i: int) -> bool:
		return not rig.spills_at(i) and i != rig.gold_index)
	assert_almost_eq(jammed.size(), 20, 1)
	rig.drawers[plain[0]].use(cop)
	assert_eq(rig.spills.size(), 0)
	rig.drawers[jammed[0]].use(cop)
	assert_eq(rig.spills.size(), 1)
	var spilled := rig.spills[0]
	watch_signals(spilled)
	cop.global_position = spilled.global_position + Vector3(0, 0.05, 0)
	cop.velocity = Vector3(GameScale.WALK_SPEED, 0, 0)
	await wait_physics_frames(1)
	assert_signal_not_emitted(spilled, "slipped", "walking is fine")
	spilled.slip(cop, Vector3.RIGHT)
	assert_signal_emitted(spilled, "slipped")


func test_the_flashlight_makes_the_golden_drawer_glint() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var rig := store.rig as GoldScrewsRig
	var front := rig.drawers[rig.gold_index].global_position
	await wait_physics_frames(2)
	assert_false(rig.glinted, "no light, no glint")
	# The beam from 2.5 m out, pointed at the drawer.
	var from := front + Vector3(2.5, 0.3, 0)
	cop.belt.flashlight.global_transform = Transform3D(Basis.looking_at(front - from), from)
	cop.belt.flashlight.toggle()
	await wait_physics_frames(2)
	assert_true(rig.glinted)
	assert_has(store.raid.clues_found, tr("CLUE_GOLD_GLINT"))


func test_the_golden_drawer_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	var rig := store.rig as GoldScrewsRig
	rig.drawers[rig.gold_index].use(cop)
	rig.gold.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(rig.gold))
	assert_true(store.raid.mark(store.raid.suspicions.find("gold_screws")))
	store.car.enter(cop)
	assert_true(store.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_GOLD_SCREWS_B", "BRIEF_GOLD_SCREWS_C", "BRIEF_GOLD_SCREWS_D", "OBJ_FIND_GOLD_SCREWS",
			"OBJ_EXTRA_SCREW_MOLD", "OBJ_EXTRA_JEWELRY_BAG", "COSME_CLUE_gold_screws", "CLUE_GOLD_GLINT",
			"PROMPT_SCREW_DRAWER", "HINT_GOLD_DRAWER", "HINT_SCREWS_SPILL", "HINT_SCREWS_SLIP", "HINT_DRAWER_PLAIN"]:
		assert_ne(tr(key), key)
