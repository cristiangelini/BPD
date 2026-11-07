extends GutTest

## The rink raid with the real sequins (allanamiento-pista.md, step 6): the leotard with diamonds solves the case in the
## patrol car's trunk; it glints in colors, brightly under the mirror ball, and the first time a cop sees it it's a
## clue; Doña Pirueta wears a dull leotard and complains that the good one is at the dry cleaner's.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "real_sequins"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_leotard_solves_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "real_sequins")
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_diamond_leotard.tscn")
	assert_eq(rink.main.mass, 1.0)
	assert_eq(rink.extras.size(), 2, "the loupe and the jewelry box")
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("real_sequins")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_it_glints_brighter_under_the_mirror_ball_and_seeing_it_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as RealSequinsRig
	var cop: Cop = rink.get_node("Cop")
	cop.global_position = Vector3(0, 0, 14.0)
	rink.main.freeze = true
	rink.main.global_position = rink.to_global(Vector3(12.0, Rink.ICE_TOP + 0.1, 5.0))
	await wait_seconds(0.5)
	assert_false(rig.under_the_ball())
	assert_almost_eq(rig.glint.light_energy, RealSequinsRig.GLINT_FAR, 0.01, "faint away from the ball")
	var color := rig.glint.light_color
	await wait_seconds(0.3)
	assert_ne(rig.glint.light_color, color, "it changes color")
	rink.main.global_position = rink.to_global(Vector3(1.0, Rink.ICE_TOP + 0.1, 1.0))
	await wait_seconds(0.5)
	assert_true(rig.under_the_ball())
	assert_almost_eq(rig.glint.light_energy, RealSequinsRig.GLINT_UNDER, 0.01, "bright under the ball")
	assert_false(rig.seen, "no cop near yet")
	cop.global_position = rink.main.global_position + Vector3(2.0, 0, 0)
	await wait_physics_frames(3)
	cop.global_position = rink.main.global_position + Vector3(1.0, 0, 0)
	await wait_physics_frames(3)
	assert_eq(rink.raid.clues_found.count(tr("CLUE_SEQUIN_GLINTS")), 1, "one clue")


func test_she_wears_a_dull_leotard_and_complains_about_the_dry_cleaner() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as RealSequinsRig
	assert_gt(rig.dulled, 0, "her own leotard is dull")
	var cop: Cop = rink.get_node("Cop")
	cop.global_position = rink.owner_npc.global_position + Vector3(1.5, 0, 0)
	await wait_physics_frames(3)
	assert_eq(rig.complaints, 1)
	assert_eq(rink.owner_npc.get_node("Bubble").text, "PIRUETA_DRY_CLEANER")
	await wait_physics_frames(10)
	assert_eq(rig.complaints, 1, "not again so soon")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_REAL_SEQUINS_B", "BRIEF_REAL_SEQUINS_C", "BRIEF_REAL_SEQUINS_D",
			"OBJ_FIND_DIAMOND_LEOTARD", "OBJ_EXTRA_LOUPE", "OBJ_EXTRA_JEWELRY_BOX", "COPITO_CLUE_real_sequins",
			"CLUE_SEQUIN_GLINTS", "PIRUETA_DRY_CLEANER"]:
		assert_ne(tr(key), key, key)
