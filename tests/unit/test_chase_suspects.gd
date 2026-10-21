extends GutTest

## What each chase suspect leaves behind (persecucion.md, "Los sospechosos"): the ice cream man's slippery puddles and
## the moving truck's furniture.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level(suspect: String) -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = suspect
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _chase(level: ChaseLevel) -> void:
	level.case.give_tip()
	level.case.car.enter(level.get_node("Cop"), 0)


func test_each_suspect_drives_his_own_vehicle() -> void:
	var level := _level("moving_truck")
	await wait_physics_frames(5)
	assert_eq(level.truck.kind, "moving_truck")
	assert_eq(level.case.suspect_id, "moving_truck")


func test_the_ice_cream_man_drips_and_the_puddles_are_slippery() -> void:
	var level := _level("ice_cream")
	await wait_physics_frames(10)
	_chase(level)
	var drops := level.case.drops
	await wait_physics_frames(roundi((ChaseDrops.DRIP_EVERY + 0.5) * Engine.physics_ticks_per_second))
	assert_gt(drops.puddles.size(), 0, "he drips ice cream as he goes")
	var car := level.case.car
	var wheel: VehicleWheel3D = car.get_node("WheelFrontLeft")
	var grip := wheel.wheel_friction_slip
	var puddle: Node3D = drops.puddles[0][0]
	car.global_position = puddle.global_position + Vector3.UP * 0.4
	await wait_physics_frames(3)
	assert_almost_eq(wheel.wheel_friction_slip, grip * ChaseDrops.PUDDLE_GRIP, 0.01, "on the ice cream, the tires slip")
	car.global_position = puddle.global_position + Vector3(10, 0.4, 0)
	await wait_physics_frames(3)
	assert_almost_eq(wheel.wheel_friction_slip, grip, 0.01, "off it, they grip again")


func test_the_moving_truck_loses_furniture_where_he_turns() -> void:
	var level := _level("moving_truck")
	await wait_physics_frames(10)
	_chase(level)
	await wait_physics_frames(3)
	var drops := level.case.drops
	assert_eq(drops.furniture.size(), 0)
	level.truck.corner_passed.emit(false)
	assert_eq(drops.furniture.size(), 0, "nothing falls going straight on")
	level.truck.corner_passed.emit(true)
	assert_eq(drops.furniture.size(), 1, "a turn and something falls off")
	var piece := drops.furniture[0]
	assert_lt(level.truck.to_local(piece.global_position).z, 0.0, "behind him")
	for i in ChaseDrops.MAX_FURNITURE + 3:
		drops.drop_furniture()
	assert_eq(drops.furniture.size(), ChaseDrops.MAX_FURNITURE, "only so much stays on the street")


func test_his_route_turns_and_he_says_so() -> void:
	var level := _level("moving_truck")
	await wait_physics_frames(10)
	_chase(level)
	watch_signals(level.truck)
	await wait_physics_frames(roundi(12.0 * Engine.physics_ticks_per_second))
	assert_signal_emitted(level.truck, "corner_passed")


func test_ramming_the_school_bus_hard_has_the_parents_complain() -> void:
	var level := _level("school_bus")
	await wait_physics_frames(10)
	_chase(level)
	await wait_physics_frames(3)
	var case := level.case
	assert_eq(level.truck.kind, "school_bus")
	assert_not_null(level.complaint_bar, "the parents' complaint shows at the top")
	case.damages.rammed.emit()
	assert_almost_eq(case.complaint, ChaseCase.RAM_COMPLAINT, 0.01)
	assert_almost_eq(level.complaint_bar.value, ChaseCase.RAM_COMPLAINT, 0.01)
	case.damages.rammed.emit()
	case.damages.rammed.emit()
	assert_true(case.case_failed, "three hard rams and they file it")
	assert_eq(case.failed_label.text, "CASE_FAILED_PARENTS")


func test_ramming_the_other_suspects_is_no_complaint() -> void:
	var level := _level("ice_cream")
	await wait_physics_frames(10)
	_chase(level)
	await wait_physics_frames(3)
	level.case.damages.rammed.emit()
	assert_eq(level.case.complaint, 0.0)
	assert_null(level.complaint_bar)


func test_a_hard_hit_on_the_bus_counts_as_a_ram() -> void:
	var level := _level("school_bus")
	await wait_physics_frames(10)
	var car := level.case.car
	car.enter(level.get_node("Cop"), 0)
	var bus := level.truck
	bus.driving = false
	car.global_transform = Transform3D(bus.global_basis, bus.global_position - bus.global_basis.z * 11.0 + Vector3.UP * 0.3)
	await wait_physics_frames(2)
	car.linear_velocity = car.global_basis.z * 15.0
	await wait_physics_frames(90)
	assert_eq(level.case.damages.rams, 1)
	assert_eq(level.case.damages.fines, 0, "ramming him is never a fine")


func test_the_kids_shout_out_of_the_windows() -> void:
	var level := _level("school_bus")
	await wait_physics_frames(10)
	_chase(level)
	await wait_physics_frames(10)
	var bubble := level.case.drops.kids_bubble
	assert_true(bubble.visible)
	assert_true(ChaseDrops.KIDS_LINES.has(bubble.text))
