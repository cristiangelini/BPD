extends GutTest

## The insurance office's shredder (docs/diseno/seguros.md, step 5): the box of claims is hidden with the bag and the
## order, a trail of paper bits leads to it (the clue), and the archive's shredder eats what's let go on it.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "shredder"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_box_of_claims_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_true(office.rig is ShredderRig)
	assert_almost_eq((office.main as RigidBody3D).mass, 4.0, 0.01)
	assert_eq(office.extras.size(), 2, "the bag and the order")
	assert_eq(office.hidden_spots.size(), 3)


func test_every_spot_has_a_trail_that_ends_at_it() -> void:
	for spot: Dictionary in InsuranceOffice.SPOTS:
		assert_true(ShredderRig.TRAILS.has(spot.id), spot.id)
		var path: Array = ShredderRig.TRAILS[spot.id]
		var end: Vector3 = path[-1]
		var at: Vector3 = spot.at
		assert_lt(Vector2(end.x - at.x, end.z - at.z).length(), 1.0, "%s's trail ends by it" % spot.id)


func test_the_trail_of_paper_bits_is_the_clue() -> void:
	for case_seed in [5, 6, 7]:
		var office := _office(case_seed)
		await wait_physics_frames(2)
		var rig := office.rig as ShredderRig
		assert_gt(rig.bits, 4, "a trail of bits")
		var spot_id: String = InsuranceOffice.SPOTS[office.hidden_spots[0]].id
		assert_lt(rig.trail.position.distance_to(ShredderRig.TRAILS[spot_id][0]), 0.05, "where the trail starts")
		rig.trail.use(office.get_node("Cop"))
		assert_has(office.raid.clues_found, tr("CLUE_PAPER_TRAIL"))
		office.free()


func test_the_shredder_eats_an_extra_left_on_it() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ShredderRig
	var bag := office.extras[0] as RigidBody3D
	bag.global_position = InsuranceOffice.SHREDDER_AT + Vector3(0, 1.0, 0)
	watch_signals(rig)
	await wait_physics_frames(20)
	assert_signal_emitted(rig, "ate")
	assert_has(rig.eaten, bag)
	assert_false(bag.visible)
	assert_false(office.raid.case_failed, "an extra is only lost")


func test_the_main_box_in_the_shredder_loses_the_case() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ShredderRig
	rig.eat(office.main)
	assert_true(office.raid.case_failed)


func test_it_doesnt_eat_what_a_cop_still_holds() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as ShredderRig
	var order := office.extras[1] as Grabbable
	order.hold(1, order.global_position)
	order.global_position = InsuranceOffice.SHREDDER_AT + Vector3(0, 0.85, 0)
	await wait_physics_frames(3)
	assert_does_not_have(rig.eaten, order)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var box := office.main
	box.global_position = office.car.to_global(Vector3(0, 0.3, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(box))
	assert_true(office.raid.mark(office.raid.suspicions.find("shredder")))
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_SHREDDER_B", "BRIEF_SHREDDER_C", "BRIEF_SHREDDER_D", "OBJ_FIND_CLAIMS_BOX",
			"OBJ_EXTRA_SHRED_BAG", "OBJ_EXTRA_SHRED_ORDER", "COCA_CLUE_shredder", "PROMPT_PAPER_TRAIL",
			"CLUE_PAPER_TRAIL", "SHREDDER_GRR", "CASE_FAILED_SHREDDED"]:
		assert_ne(tr(key), key)
