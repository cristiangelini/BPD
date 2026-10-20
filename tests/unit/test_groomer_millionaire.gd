extends GutTest

## The millionaire's dog (docs/diseno/peluqueria.md, "El perro del millonario"): Duque among four brown greyhounds,
## his white roots up close, wriggling when held, running off when let go, and the trunk.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "millionaire"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func test_duque_is_one_of_four_brown_greyhounds() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var rig := groomer.rig as MillionaireRig
	assert_eq(rig.greyhounds.size(), 4)
	assert_has(rig.greyhounds, rig.duque)
	assert_eq(groomer.main, rig.duque)
	assert_lt(rig.duque.mass, GameScale.COP_CARRY_KG, "one cop can carry him")
	for dog in rig.greyhounds:
		assert_eq(dog.full_value, 1500.0 if dog == rig.duque else 0.0)
		assert_null(dog.get_node_or_null("ValueLabel"), "no number gives him away")


func test_his_white_roots_show_up_close() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as MillionaireRig
	assert_false(groomer.raid.clues_found.has(tr("CLUE_MILLIONAIRE_ROOTS")))
	cop.global_position = rig.duque.global_position + Vector3(0.8, 0.1, 0)
	await wait_physics_frames(2)
	assert_has(groomer.raid.clues_found, tr("CLUE_MILLIONAIRE_ROOTS"))


func test_let_go_outside_the_trunk_he_runs_off() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as MillionaireRig
	var grabber: Grabber = cop.get_node("Grabber")
	cop.global_position = rig.duque.global_position + Vector3(0, 0.1, 1.2)
	grabber.grab(rig.duque)
	await wait_physics_frames(2)
	assert_eq(rig.escaping, 0.0, "not while he's held")
	grabber.release()
	await wait_physics_frames(2)
	assert_gt(rig.escaping, 0.0)
	assert_eq(rig.duque.flee, MillionaireRig.ESCAPE_RANGE)


func test_duque_in_the_trunk_stays_and_solves_the_case_but_a_decoy_does_not_count() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as MillionaireRig
	var decoy: Dog = rig.greyhounds[(rig.greyhounds.find(rig.duque) + 1) % 4]
	decoy.global_position = groomer.car.to_global(Vector3(0.4, 0.8, -1.7))
	rig.duque.global_position = groomer.car.to_global(Vector3(-0.3, 0.8, -1.7))
	await wait_physics_frames(15)
	assert_false(groomer.car.is_delivered(decoy), "a plain dog isn't evidence")
	assert_true(groomer.car.is_delivered(rig.duque))
	assert_true(rig.duque.caged, "he lies down in the trunk")
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("millionaire")))
	groomer.car.enter(cop)
	assert_true(groomer.raid.case_solved)
