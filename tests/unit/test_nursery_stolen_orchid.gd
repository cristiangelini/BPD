extends GutTest

## The nursery raid with the stolen orchid (allanamiento-vivero.md, step 6): the same case as every raid, the orchid in
## the patrol car's trunk, the butterflies over it near a cop, the plants leaning toward it, Doña Hortensia's slips
## and Brotecito's clue.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "stolen_orchid"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_orchid_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "stolen_orchid")
	assert_eq(nursery.raid.suspicions.size(), 3)
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/nursery_orchid.tscn")
	assert_eq(nursery.extras.size(), 2, "the catalog and the shears")
	assert_eq(nursery.raid.owner_npc, nursery.owner_npc)
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("stolen_orchid")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_the_butterflies_follow_the_orchid_and_are_a_clue_near_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as StolenOrchidRig
	assert_eq(rig.butterflies.size(), StolenOrchidRig.BUTTERFLIES)
	var over := nursery.main.global_position + Vector3.UP * StolenOrchidRig.CLOUD_HEIGHT
	assert_lt(rig.butterflies[0].global_position.distance_to(over), StolenOrchidRig.CLOUD_RADIUS + 0.3, "over it")
	assert_false(rig.noticed, "nobody near them")
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.main.global_position + Vector3(1.5, 0.2, 0)
	await wait_seconds(StolenOrchidRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_BUTTERFLIES")), 1, "one clue")


func test_the_plants_lean_toward_the_orchid() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var plant := nursery.flowers[0]
	var to := nursery.to_local(nursery.main.global_position) - plant.position
	assert_almost_eq(plant.rotation.y, atan2(to.x, to.z), 0.01)
	assert_almost_eq(plant.rotation.x, StolenOrchidRig.LEAN, 0.01)


func test_hortensia_slips_and_brotecito_tells_where_she_hid_something() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	assert_eq(nursery.owner_npc.slips.size(), 3)
	var where := tr("LOC_" + Nursery.SPOTS[nursery.hidden_spots[5 % 3]].id)
	assert_string_contains(nursery.kid.clue_speech, where)
	var cop: Cop = nursery.get_node("Cop")
	cop.get_node("Grabber").grab(nursery.can)
	nursery.can.fill()
	nursery.kid.take(nursery.can)
	assert_has(nursery.raid.clues_found, nursery.kid.clue)


func test_the_lawyer_loses_the_case_and_fines_count() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	nursery.break_pot(0)
	assert_eq(nursery.raid.fines, Nursery.POT_FINE)
	nursery.owner_npc.scold(FloorBoss.MAX_COMPLAINT, "HORTENSIA_LAWYER")
	assert_true(nursery.raid.case_failed)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_NURSERY_TIP_B", "BRIEF_NURSERY_TIP_D", "BRIEF_NURSERY_TIP_E", "BRIEF_STOLEN_ORCHID_B",
			"BRIEF_STOLEN_ORCHID_C", "BRIEF_STOLEN_ORCHID_D", "OBJ_FIND_ORCHID", "OBJ_EXTRA_CATALOG",
			"OBJ_EXTRA_SHEARS", "OBJ_ENTER_NURSERY", "OBJ_GUESS_NURSERY", "OBJ_BROKEN_NURSERY",
			"OBJ_COMPLAINT_NURSERY", "HORTENSIA_SLIP", "CLUE_BROTECITO", "BROTECITO_CLUE_stolen_orchid",
			"CLUE_BUTTERFLIES", "NURSERY_BUTTERFLIES", "CASE_FAILED_LAWYER_NURSERY", "CRIME_owner_nursery",
			"CONFESS_owner_nursery"]:
		assert_ne(tr(key), key, key)
	for id: String in Nursery.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_nursery"]))
