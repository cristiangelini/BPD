extends GutTest

## The cow of many owners story (docs/diseno/allanamiento-granja.md, step 6): its folder of receipts, cowbell and brush,
## the black hand a pat on Margarita leaves (her spots are fresh paint) and the gate that swings open by itself.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 5) -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = "many_owners_cow"
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_story_hides_the_receipts_the_cowbell_and_the_brush() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_eq(farm.raid.story_id, "many_owners_cow")
	assert_true(farm.rig is CowOwnersRig)
	assert_eq(farm.hidden.size(), 3)
	assert_eq(farm.main.mass, 1.0)
	assert_eq(farm.main.full_value, 1000.0)
	assert_eq(farm.extras.map(func(e: Evidence) -> float: return e.full_value), [300.0, 200.0])
	assert_false(FarmGoat.is_paper(farm.main), "a 1 kg folder is too much for Tota")
	assert_has(farm.raid.suspicions, "many_owners_cow")
	assert_eq(FarmRaid.pick_story(3, PackedStringArray(["--story=many_owners_cow"])), "many_owners_cow")


func test_a_pat_on_margarita_leaves_a_black_hand_and_the_clue_once() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	var rig := farm.rig as CowOwnersRig
	watch_signals(rig)
	assert_eq(farm.cow.prompt_key(cop), "PROMPT_PET_COW")
	farm.cow.use(cop)
	assert_signal_emitted(rig, "painted")
	assert_true(cop.get_meta("black_hand", false), "her spots are fresh paint")
	assert_true(farm.raid.clues_found.has(tr("CLUE_COW_PAINT")))
	var clues := farm.raid.clues_found.size()
	farm.cow.use(cop)
	assert_eq(farm.raid.clues_found.size(), clues, "the clue goes on the checklist only once")


func test_the_gate_swings_open_by_itself() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_false(farm.corral_gate.is_open)
	var rig := farm.rig as CowOwnersRig
	rig._open_left = 0.05
	await wait_physics_frames(10)
	assert_true(farm.corral_gate.is_open, "she's used to leaving with buyers")
	farm.corral_gate.set_open(false)
	rig.open_gate()
	assert_true(farm.corral_gate.is_open)
