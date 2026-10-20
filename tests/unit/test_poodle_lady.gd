extends GutTest

## The poodle lady and Fifí (docs/diseno/peluqueria.md, step 4).

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer() -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.get_node("Cop").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func test_fifi_waits_in_her_cage_until_a_cop_takes_her_out() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	var start := groomer.poodle.global_position
	await wait_seconds(2.0)
	assert_lt(groomer.poodle.global_position.distance_to(start), 0.05, "she stays in the cage")
	assert_true(groomer.poodle.caged)
	var cop: Cop = groomer.get_node("Cop")
	cop.get_node("Grabber").grab(groomer.poodle)
	await wait_physics_frames(2)
	assert_false(groomer.poodle.caged, "out of the cage, she's a loose dog")


func test_the_lady_asks_for_fifi_once() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(2)
	watch_signals(groomer.lady)
	groomer.lady.use(cop)
	groomer.lady.use(cop)
	assert_signal_emit_count(groomer.lady, "asked", 1)
	assert_true(groomer.lady.was_asked)


func test_bringing_fifi_gets_the_clue() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	groomer.lady.clue = "CLUE_TEST"
	watch_signals(groomer.lady)
	cop.global_position = groomer.lady.global_position + Vector3(0, 0.1, -2.5)
	cop.get_node("Grabber").grab(groomer.poodle)
	groomer.poodle.global_position = cop.global_position + Vector3(0, 1.0, 0.5)
	# Carried up to her: once in her arms' reach, she takes her.
	for i in 60:
		cop.global_position.z += 0.03
		await wait_physics_frames(1)
		if groomer.lady.returned:
			break
	assert_true(groomer.lady.returned, "Fifí reached her arms")
	assert_signal_emitted_with_parameters(groomer.lady, "told", ["CLUE_TEST"])
	assert_null(cop.get_node("Grabber").held, "the cop let go")
	assert_false(groomer.poodle.is_in_group("dogs"), "in her arms she's not a loose dog anymore")


func test_other_dogs_are_not_fifi() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var dog := groomer.dogs[0]
	dog.global_position = groomer.lady.global_position + Vector3(0, 0.5, -0.8)
	await wait_physics_frames(10)
	assert_false(groomer.lady.returned)
