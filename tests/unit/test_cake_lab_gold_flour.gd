extends GutTest

## The cake lab with the gold flour's story (docs/diseno/laboratorio.md, step 5): the sack with the gold among the
## real ones, its value hidden until picked up, the gold leak and the golden footprints as the clue.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "gold_flour"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_the_gold_sack_stands_among_the_real_ones() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as GoldFlourRig
	assert_eq(lab.main, rig.sack)
	assert_almost_eq(rig.sack.mass, 10.0, 0.01)
	assert_eq(lab.sacks.size(), 9, "nine real ones and the gold one")
	var row := CakeLab.SACK_ROWS[rig.replaced / CakeLab.SACK_ALONG.size()]
	var along := CakeLab.SACK_ALONG[rig.replaced % CakeLab.SACK_ALONG.size()]
	assert_almost_eq(rig.sack.position.x, row, 0.01)
	assert_almost_eq(rig.sack.position.z, along, 0.01)
	assert_false(rig.sack.get_node("ValueLabel").visible, "no value giving it away")
	assert_eq(lab.extras.size(), 2, "the sieve and the invoice")


func test_its_value_shows_once_picked_up() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as GoldFlourRig
	rig.sack.hold(1, rig.sack.global_position)
	await wait_physics_frames(2)
	assert_true(rig.sack.get_node("ValueLabel").visible)
	rig.sack.let_go(1)


func test_stepping_in_the_leak_leaves_golden_prints_and_a_clue() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as GoldFlourRig
	var cop: Cop = lab.get_node("Cop")
	var leak := Vector3(rig.sack.position.x, CakeLab.FLOOR_TOP, rig.sack.position.z) + GoldFlourRig.LEAK_OFFSET
	cop.global_position = leak
	await wait_physics_frames(2)
	assert_has(lab.raid.clues_found, tr("CLUE_GOLD_PRINTS"))
	assert_true(lab.flour.gold_boots.get(cop, false))
	for i in 4:
		cop.global_position = Vector3(-8.0, CakeLab.FLOOR_TOP, -1.5 + i * 0.0) + Vector3(0, 0, i * 0.7)
		await wait_physics_frames(1)
	assert_gt(lab.flour.prints.size(), 0)
	var mark: MeshInstance3D = lab.flour.prints[-1][0]
	assert_eq((mark.mesh.material as StandardMaterial3D).albedo_color, FlourPrints.GOLD, "golden prints")
	var clues: int = lab.raid.clues_found.size()
	cop.global_position = leak
	await wait_physics_frames(2)
	assert_eq(lab.raid.clues_found.size(), clues, "the clue only once")


func test_a_real_sack_still_bursts_white() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	lab.sacks[0].hit(FlourSack.BURST_SPEED + 1.0)
	assert_eq(lab.burst_sacks, 1)
	assert_false(lab.flour.patches[-1][3], "white flour")


func test_the_sack_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	lab.main.global_position = lab.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(lab.main))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("gold_flour")))
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_GOLD_FLOUR_B", "BRIEF_GOLD_FLOUR_C", "BRIEF_GOLD_FLOUR_D", "OBJ_FIND_GOLD_FLOUR",
			"OBJ_EXTRA_GOLD_SIEVE", "OBJ_EXTRA_JEWELER_INVOICE", "POCHA_CLUE_gold_flour", "HINT_GOLD_FLOUR",
			"CLUE_GOLD_PRINTS"]:
		assert_ne(tr(key), key)
