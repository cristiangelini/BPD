extends GutTest

## The turtle races story (historias.md, "Carreras de tortugas").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const TURTLE_SCENE := preload("res://scenes/props/turtle_plain.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.TURTLES
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_relampago_and_four_lookalikes_are_in_the_house() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var rig: TurtleRig = house.rig
	assert_eq(house.main_evidence().scene_file_path, "res://scenes/props/turtle_racer.tscn")
	assert_eq(rig.decoys.size(), TurtleRig.DECOYS)
	for turtle in rig.decoys:
		assert_false(turtle is Evidence, "a plain turtle is worth nothing")
	assert_eq(house.drawer_evidence.size(), 3, "three trophies in the drawers")
	assert_true((house.main_evidence().get_node("Walk") as TurtleWalk).asleep, "Relámpago sleeps until a cop comes")


func test_lettuce_leads_to_relampago_and_footprints_to_the_board() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(15)
	var lettuce: Array = house.trails[tr("CLUE_LETTUCE")]
	assert_gt(lettuce.size(), 5)
	var last: Node3D = lettuce[lettuce.size() - 1]
	var racer := house.main_evidence()
	assert_lt(Vector2(last.global_position.x - racer.global_position.x, last.global_position.z - racer.global_position.z).length(),
		2.0, "the leaves end by Relámpago")
	assert_eq(house.clue_plan.footprints, TurtleRig.BOARD)
	assert_eq(house.notes.size(), 2, "one note for each item")


func test_the_checklist_asks_for_relampago_and_counts_the_trophies() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(30)
	var trophy: Evidence = house.drawer_evidence[0]
	trophy.global_position = house.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	var rows := CaseObjectives.rows(house.objective_facts())
	var texts := rows.map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "OBJ_FIND_TURTLE")
	assert_has(texts, "OBJ_EXTRA_BOARD")
	assert_has(texts, "Extra: trofeos (1 de 3), en los cajones")


func test_a_turtle_walks_slowly_hides_near_a_cop_and_stops_when_held() -> void:
	var turtle: Grabbable = TURTLE_SCENE.instantiate()
	add_child_autofree(turtle)
	var walk: TurtleWalk = turtle.get_node("Walk")
	for i in 3:
		walk._physics_process(0.1)
	var speed := Vector2(turtle.linear_velocity.x, turtle.linear_velocity.z).length()
	assert_almost_eq(speed, TurtleWalk.SPEED, 0.01, "it walks at turtle speed")
	turtle.hold(1, turtle.global_position)
	turtle.linear_velocity = Vector3.ZERO
	walk._physics_process(0.1)
	assert_eq(turtle.linear_velocity, Vector3.ZERO, "a held turtle doesn't walk")


func test_a_sleeping_turtle_wakes_when_a_cop_comes_close() -> void:
	var house := _house()
	await wait_physics_frames(2)
	var racer := house.main_evidence()
	var walk: TurtleWalk = racer.get_node("Walk")
	var cop: Cop = house.get_node("Cop")
	cop.global_position = racer.global_position + Vector3(TurtleWalk.WAKE_RANGE + 2.0, 0, 0)
	await wait_physics_frames(3)
	assert_true(walk.asleep)
	cop.global_position = racer.global_position + Vector3(TurtleWalk.WAKE_RANGE - 1.0, 0, 0)
	await wait_physics_frames(3)
	assert_false(walk.asleep)
	cop.global_position = racer.global_position + Vector3(TurtleWalk.SHELL_RANGE - 0.4, 0, 0)
	await wait_physics_frames(3)
	assert_true(walk.in_shell, "right next to a cop it hides in its shell")
