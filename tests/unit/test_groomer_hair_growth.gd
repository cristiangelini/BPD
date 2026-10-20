extends GutTest

## The hair-growth shampoo (docs/diseno/peluqueria.md, "El champú crecepelo"): the jug, the long-haired caged dog
## and the mustache from the bathtub's puddle.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "hair_growth"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func test_the_jug_is_the_main_evidence_in_a_big_spot() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	assert_eq(groomer.main.scene_file_path, "res://scenes/props/shampoo_jug.tscn")
	assert_true(Groomer.SPOTS[groomer.hidden_spots[0]].heavy)
	assert_eq(groomer.extras.size(), 2)


func test_the_long_haired_dog_in_its_cage_is_the_clue() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	assert_false(groomer.caged_looks[HairGrowthRig.LONG_HAIR_CAGE].visible, "the usual dog is swapped for the long-haired one")
	var cage := Vector3(Groomer.CAGE_XS[HairGrowthRig.LONG_HAIR_CAGE.x], 0.1, Groomer.CAGE_Z + 1.2)
	cop.global_position = cage
	await wait_physics_frames(2)
	assert_has(groomer.raid.clues_found, tr("CLUE_HAIR_GROWTH_DOG"))


func test_stepping_in_the_puddle_grows_a_mustache_for_a_while() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as HairGrowthRig
	cop.global_position = HairGrowthRig.PUDDLE_AT + Vector3(0, 0.1, 0)
	await wait_physics_frames(5)
	assert_true(rig.mustaches.has(cop))
	assert_not_null(cop.get_node_or_null("Head/Mustache"), "it covers the bottom of the view")
	cop.global_position = Vector3(3.0, 0.1, 5.5)
	rig.mustaches[cop] = 0.05
	await wait_physics_frames(10)
	assert_false(rig.mustaches.has(cop))
	assert_null(cop.get_node_or_null("Head/Mustache"), "and goes away")


func test_the_jug_in_the_trunk_solves_the_case() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	groomer.main.global_position = groomer.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(groomer.car.is_delivered(groomer.main))
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("hair_growth")))
	groomer.car.enter(groomer.get_node("Cop"))
	assert_true(groomer.raid.case_solved)
