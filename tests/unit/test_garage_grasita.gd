extends GutTest

## Grasita and the tools (docs/diseno/allanamiento-taller.md, step 3): E on him and he asks for one of the bench's
## tools; the right one brought into his hands and he tells what he saw, once per cop; another one gets "That's not
## it!" and is tossed back.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_bench_has_every_tool_he_can_ask_for() -> void:
	var garage := _garage()
	await wait_physics_frames(30)
	assert_eq(garage.tools.size(), GarageApprentice.TOOLS.size())
	for id: String in GarageApprentice.TOOLS:
		var tool: Grabbable = garage.tools[id]
		assert_gt(garage.to_local(tool.global_position).y, Garage.FLOOR_TOP + 0.8, "%s stays on the bench" % id)
		assert_ne(tr("GARAGE_TOOL_" + id.to_upper()), "GARAGE_TOOL_" + id.to_upper(), "%s has its name" % id)


func test_he_asks_for_the_same_tool_until_it_comes() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	garage.grasita.use(cop)
	var wanted := garage.grasita.wanted
	assert_has(GarageApprentice.TOOLS, wanted)
	garage.grasita.use(cop)
	assert_eq(garage.grasita.wanted, wanted)
	var other := _garage()
	await wait_physics_frames(2)
	other.grasita.use(other.get_node("Cop"))
	assert_eq(other.grasita.wanted, wanted, "the same seed asks for the same tool")


func test_the_right_tool_and_he_tells_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	garage.grasita.clue = "seen"
	garage.grasita.clue_speech = "I saw him"
	watch_signals(garage.grasita)
	garage.grasita.use(cop)
	garage.grasita.hand(garage.tools[garage.grasita.wanted], cop)
	assert_signal_emitted_with_parameters(garage.grasita, "told", ["seen"])
	assert_true(garage.grasita.listeners.has(cop))
	assert_eq(garage.grasita.wanted, "")
	garage.grasita.use(cop)
	assert_eq(garage.grasita.wanted, "", "nothing more for the same cop")


func test_a_wrong_tool_is_tossed_back() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	garage.grasita.use(cop)
	var wrong: String = GarageApprentice.TOOLS[(GarageApprentice.TOOLS.find(garage.grasita.wanted) + 1) % 8]
	var tool: Grabbable = garage.tools[wrong]
	garage.grasita.hand(tool, cop)
	assert_false(garage.grasita.listeners.has(cop))
	assert_gt(tool.linear_velocity.length(), 1.0, "back it goes")


func test_a_tool_carried_into_his_hands_counts() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	garage.grasita.use(cop)
	var tool: Grabbable = garage.tools[garage.grasita.wanted]
	var grabber: Grabber = cop.get_node("Grabber")
	tool.hold(grabber.get_instance_id(), tool.global_position)
	tool.let_go(grabber.get_instance_id())
	tool.global_position = garage.grasita.global_position + Vector3(0, 0.9, 0)
	await wait_physics_frames(4)
	assert_true(garage.grasita.listeners.has(cop))
