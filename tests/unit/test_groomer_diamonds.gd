extends GutTest

## The diamond necklace (docs/diseno/peluqueria.md, "El collar de diamantes"): a loose dog wears it, runs from cops,
## moves around, shines under the dryers, and grabbing the necklace takes it off.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "diamonds"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func test_every_story_comes_up_with_the_seed() -> void:
	var drawn := {}
	for i in 20:
		drawn[Groomer.pick_story(i + 1, [])] = true
	assert_eq(drawn.size(), Groomer.STORIES.size())
	assert_eq(Groomer.pick_story(4, ["--story=diamonds"]), "diamonds")


func test_a_dog_wears_the_necklace_and_runs_from_cops() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(10)
	var rig := groomer.rig as DiamondsRig
	assert_eq(groomer.main, rig.necklace)
	assert_has(DiamondsRig.WEARERS.map(func(i: int) -> Dog: return groomer.dogs[i]), rig.wearer)
	assert_lt(_flat(rig.necklace.global_position, rig.wearer.global_position), 0.4, "around its neck")
	rig.wearer.global_position = Vector3(-4.0, Groomer.FLOOR_TOP + 0.05, 5.0)
	cop.global_position = Vector3(-5.5, 0.1, 5.0)
	await wait_physics_frames(3)
	var start := _flat(rig.wearer.global_position, cop.global_position)
	await wait_seconds(0.8)
	assert_gt(_flat(rig.wearer.global_position, cop.global_position), start + 0.5, "it runs away")
	assert_eq(rig.wearer.state, Dog.State.WANDER, "and doesn't follow cops")


func test_it_moves_to_another_part_of_the_salon_every_so_often() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var rig := groomer.rig as DiamondsRig
	var before := rig.stop
	rig._move_left = 0.0
	await wait_physics_frames(2)
	assert_eq(rig.stop, (before + 1) % DiamondsRig.STOPS.size())
	var at := DiamondsRig.STOPS[rig.stop]
	assert_true(rig.wearer.areas[0].has_point(Vector2(at.x, at.z)))


func test_it_shines_under_a_dryer_and_a_cop_close_by_sees_it() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as DiamondsRig
	rig.wearer.global_position = Vector3(-4.0, Groomer.FLOOR_TOP + 0.05, 5.0)
	await wait_physics_frames(2)
	assert_false(rig.shining)
	cop.global_position = Vector3(3.5, 0.1, 3.2)
	rig.wearer.global_position = Vector3(Groomer.TABLES[0].x + 0.3, Groomer.FLOOR_TOP + 0.05, Groomer.DRYER_Z)
	await wait_physics_frames(2)
	assert_true(rig.shining)
	assert_has(groomer.raid.clues_found, tr("CLUE_DIAMONDS_SHINE"))


func test_grabbing_the_necklace_takes_it_off_and_the_trunk_solves_the_case() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as DiamondsRig
	cop.global_position = rig.wearer.global_position + Vector3(0, 0.1, 1.2)
	cop.get_node("Grabber").grab(rig.necklace)
	await wait_physics_frames(2)
	assert_false(rig.worn)
	assert_false(rig.necklace.freeze)
	assert_eq(rig.wearer.flee, 0.0, "a dog like the others again")
	cop.get_node("Grabber").release()
	rig.necklace.global_position = groomer.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(groomer.car.is_delivered(rig.necklace))
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("diamonds")))
	groomer.car.enter(cop)
	assert_true(groomer.raid.case_solved)
