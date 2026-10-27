extends GutTest

## The rink raid with the ice surprise (allanamiento-pista.md, step 5): the same case as every raid, the block of ice
## with the jewels in the patrol car's trunk, the block that glitters near a cop, the puddles to the office, Doña
## Pirueta's slips and Copito's clue.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "ice_surprise"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_ice_block_solves_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "ice_surprise")
	assert_eq(rink.raid.suspicions.size(), 3)
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_ice_block.tscn")
	assert_gt(rink.main.mass, GameScale.COP_CARRY_KG, "one cop can't carry it")
	assert_true(Rink.SPOTS[rink.hidden_spots[0]].heavy, "it's in a spot for heavy things")
	assert_eq(rink.extras.size(), 2, "the list of jewelers and the chisel")
	assert_eq(rink.raid.owner_npc, rink.owner_npc)
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("ice_surprise")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_the_block_glitters_near_a_cop_and_the_first_time_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as IceSurpriseRig
	assert_eq(rig.glitters, 0, "nobody near it")
	assert_gt(rig.puddles.size(), 0, "a trail of puddles to the office")
	rink.get_node("Cop").global_position = rink.main.global_position + Vector3(1.5, 0.1, 0)
	await wait_seconds(IceSurpriseRig.GLITTER_EVERY * 2 + 0.2)
	assert_gt(rig.glitters, 1)
	assert_eq(rink.raid.clues_found.count(tr("CLUE_ICE_GLITTERS")), 1, "one clue")


func test_dona_pirueta_slips_and_copito_tells_where_she_hid_something() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	assert_eq(rink.owner_npc.slips.size(), 3)
	assert_string_contains(rink.copito.clue_speech, tr("LOC_" + Rink.SPOTS[rink.hidden_spots[5 % 3]].id))
	var cop: Cop = rink.get_node("Cop")
	var cup := rink.pour_cocoa()
	cop.global_position = rink.to_global(Rink.COPITO_AT + Vector3(0, 0.1, 1.2))
	await wait_physics_frames(2)
	cup.global_position = (cop.get_node("Grabber") as Node).hold_point()
	(cop.get_node("Grabber") as Node).grab(cup)
	await wait_physics_frames(5)
	rink.copito.use(cop)
	assert_has(rink.raid.clues_found, rink.copito.clue)


func test_the_lawyer_loses_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	rink.owner_npc.scold(FloorBoss.MAX_COMPLAINT, "PIRUETA_LAWYER")
	assert_true(rink.raid.case_failed)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_RINK_TIP_B", "BRIEF_RINK_TIP_D", "BRIEF_RINK_TIP_E", "BRIEF_ICE_SURPRISE_B",
			"BRIEF_ICE_SURPRISE_C", "BRIEF_ICE_SURPRISE_D", "OBJ_FIND_ICE_BLOCK", "OBJ_EXTRA_JEWELER_LIST",
			"OBJ_EXTRA_ICE_CHISEL", "OBJ_ENTER_RINK", "OBJ_GUESS_RINK", "OBJ_BROKEN_RINK", "OBJ_COMPLAINT_RINK",
			"PIRUETA_SLIP", "CLUE_COPITO", "COPITO_CLUE_ice_surprise", "CLUE_ICE_GLITTERS", "RINK_GLITTER",
			"CASE_FAILED_LAWYER_RINK", "CRIME_owner_rink", "CONFESS_owner_rink"]:
		assert_ne(tr(key), key, key)
	for id: String in Rink.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
