extends GutTest

## The fun fair raid with the unchecked Ferris wheel (allanamiento-parque.md, step 6): the fake safety certificate in
## the patrol car's trunk, the loose nuts in front of the wheel and the crank that shakes another one off.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "loose_wheel"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_certificate_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	assert_has(fair.raid.suspicions, "loose_wheel")
	assert_eq(fair.main.scene_file_path, "res://scenes/props/fair_safety_certificate.tscn")
	assert_eq(fair.extras.size(), 2, "the bag of nuts and the stamp")
	fair.main.global_position = fair.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("loose_wheel")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_picking_up_a_loose_nut_is_the_clue_once() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	var rig := fair.rig as LooseWheelRig
	assert_eq(rig.nuts.size(), LooseWheelRig.NUTS.size())
	var cop: Cop = fair.get_node("Cop")
	cop.global_position = rig.nuts[0].global_position + Vector3(0, 0.1, 1.0)
	await wait_physics_frames(2)
	(cop.get_node("Grabber") as Node).grab(rig.nuts[0])
	await wait_physics_frames(2)
	(cop.get_node("Grabber") as Node).grab(rig.nuts[1])
	await wait_physics_frames(2)
	assert_eq(fair.raid.clues_found.count(tr("CLUE_LOOSE_NUTS")), 1)


func test_the_crank_shakes_a_nut_off_the_wheel() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as LooseWheelRig
	fair.rides.press("wheel")
	assert_eq(rig.drops, 1)
	assert_eq(rig.nuts.size(), LooseWheelRig.NUTS.size() + 1)
	var nut := rig.nuts[-1]
	await wait_seconds(1.5)
	assert_lt(fair.to_local(nut.global_position).y, 0.3, "it fell to the ground")
	for i in LooseWheelRig.DROPS_MAX + 2:
		rig.shake()
	assert_eq(rig.drops, LooseWheelRig.DROPS_MAX)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_LOOSE_WHEEL_B", "BRIEF_LOOSE_WHEEL_C", "BRIEF_LOOSE_WHEEL_D",
			"OBJ_FIND_SAFETY_CERTIFICATE", "OBJ_EXTRA_NUT_BAG", "OBJ_EXTRA_INSPECTOR_STAMP", "NUBE_CLUE_loose_wheel",
			"CLUE_LOOSE_NUTS", "FAIR_WHEEL_RATTLE"]:
		assert_ne(tr(key), key, key)
