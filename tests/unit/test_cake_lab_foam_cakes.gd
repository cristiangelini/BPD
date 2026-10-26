extends GutTest

## The cake lab with the foam cakes' story (docs/diseno/laboratorio.md, step 5): the mold's box and its extras hidden
## with the seed, and half the showcase made of foam: those cakes bounce instead of squashing, and the first bounce is
## the clue.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "foam_cakes"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_the_mold_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.main, lab.hidden[0])
	assert_almost_eq((lab.main as RigidBody3D).mass, 4.0, 0.01)
	assert_true(CakeLab.SPOTS[lab.hidden_spots[0]].heavy)
	assert_eq(lab.extras.size(), 2, "the diploma and the spray")


func test_half_the_showcase_is_foam_drawn_with_the_seed() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as FoamCakesRig
	assert_eq(rig.foam.size(), FoamCakesRig.FOAM)
	var other := _lab(6)
	await wait_physics_frames(2)
	var mine := rig.foam.map(func(c: Ornament) -> int: return lab.cakes.find(c))
	var theirs := (other.rig as FoamCakesRig).foam.map(func(c: Ornament) -> int: return other.cakes.find(c))
	assert_ne(mine, theirs, "another seed, other fakes")


func test_a_foam_cake_takes_a_hit_and_a_real_one_squashes() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as FoamCakesRig
	var fake := rig.foam[0]
	assert_false(fake.hit(Ornament.BREAK_SPEED + 5.0), "foam never breaks")
	assert_false(fake.is_broken)
	var real: Ornament = lab.cakes.filter(func(c: Ornament) -> bool: return not rig.is_foam(c))[0]
	assert_true(real.hit(Ornament.BREAK_SPEED + 1.0))
	assert_eq(lab.fines, Ornament.FINE, "only the real one is a fine")


func test_a_dropped_foam_cake_bounces_and_the_first_bounce_is_a_clue() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var rig := lab.rig as FoamCakesRig
	var fake := rig.foam[0]
	fake.global_position = Vector3(0.0, CakeLab.FLOOR_TOP + 1.5, 4.5)
	fake.linear_velocity = Vector3.ZERO
	var peak := [0.0]
	var landed := [false]
	for i in 90:
		await wait_physics_frames(1)
		if fake.linear_velocity.y > 0.5:
			landed[0] = true
		if landed[0]:
			peak[0] = maxf(peak[0], fake.global_position.y)
	assert_false(fake.is_broken)
	assert_gt(rig.bounces, 0)
	assert_gt(peak[0], CakeLab.FLOOR_TOP + 0.4, "it came back up")
	assert_has(lab.raid.clues_found, tr("CLUE_FOAM_BOUNCE"))
	assert_eq(lab.fines, 0)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	lab.main.global_position = lab.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(lab.main))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("foam_cakes")))
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FOAM_CAKES_B", "BRIEF_FOAM_CAKES_C", "BRIEF_FOAM_CAKES_D", "OBJ_FIND_FOAM_MOLD",
			"OBJ_EXTRA_CONTEST_DIPLOMA", "OBJ_EXTRA_CREAM_SPRAY", "POCHA_CLUE_foam_cakes", "CLUE_FOAM_BOUNCE",
			"FOAM_BOING"]:
		assert_ne(tr(key), key)
