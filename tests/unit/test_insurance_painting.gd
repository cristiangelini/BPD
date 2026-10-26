extends GutTest

## The insurance office's insured painting (docs/diseno/seguros.md, step 5): eight paintings hang on the walls, the real
## one drawn with the seed, the copies are fragile goods, the frame's clean mark in the meeting room is the clue, and
## a painting comes off its wall when grabbed.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "insured_painting"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_eight_paintings_hang_and_the_seed_picks_the_real_one() -> void:
	var office := _office()
	await wait_physics_frames(5)
	var rig := office.rig as InsuredPaintingRig
	assert_eq(rig.paintings.size(), 8)
	assert_eq(rig.copies.size(), 7, "the rest are copies")
	assert_eq(office.main, rig.real)
	assert_eq(rig.paintings.find(rig.real), InsuredPaintingRig.real_spot(5))
	assert_almost_eq((rig.real as RigidBody3D).mass, 6.0, 0.01)
	assert_eq(office.extras.size(), 2, "the policy and the tubes")
	for i in rig.paintings.size():
		assert_lt(rig.paintings[i].position.distance_to(InsuredPaintingRig.WALLS[i]), 0.01, "still on its wall")
	assert_ne(InsuredPaintingRig.real_spot(5), InsuredPaintingRig.real_spot(6), "another seed, another painting")


func test_a_painting_comes_off_its_wall_when_grabbed() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as InsuredPaintingRig
	var copy := rig.copies[0]
	assert_true(copy.freeze)
	copy.hold(1, copy.global_position)
	await wait_physics_frames(2)
	assert_false(copy.freeze)


func test_the_frame_mark_is_the_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as InsuredPaintingRig
	assert_eq(rig.mark.prompt_key(office.get_node("Cop")), "PROMPT_FRAME_MARK")
	rig.mark.use(office.get_node("Cop"))
	assert_has(office.raid.clues_found, tr("CLUE_FRAME_MARK"))


func test_a_broken_copy_is_a_fine() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as InsuredPaintingRig
	var before := office.fines
	rig.copies[0].hit(5.0)
	assert_gt(office.fines, before)


func test_the_real_one_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(5)
	var painting := office.main
	painting.freeze = false
	painting.global_position = office.car.to_global(Vector3(0, 0.5, -1.7))
	await wait_physics_frames(15)
	assert_true(office.car.is_delivered(painting))
	assert_true(office.raid.mark(office.raid.suspicions.find("insured_painting")))
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_INSURED_PAINTING_B", "BRIEF_INSURED_PAINTING_C", "BRIEF_INSURED_PAINTING_D",
			"OBJ_FIND_INSURED_PAINTING", "OBJ_EXTRA_PAINTING_POLICY", "OBJ_EXTRA_PAINT_TUBES",
			"COCA_CLUE_insured_painting", "PROMPT_FRAME_MARK", "CLUE_FRAME_MARK", "HINT_REAL_PAINTING"]:
		assert_ne(tr(key), key)
