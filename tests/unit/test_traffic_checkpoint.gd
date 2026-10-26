extends GutTest

## Traffic control step 1 (control-transito.md): the checkpoint works with the barrier across the lane in its box and
## at least two cones standing before it.

var checkpoint: TrafficCheckpoint


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))


func _barrier(local: Vector3, turn := 0.0) -> RoadBarrier:
	var barrier := RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	barrier.global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.UP, turn), local)
	return barrier


func _cone(local: Vector3) -> TrafficCone:
	var cone := TrafficCone.new()
	cone.freeze = true
	add_child_autofree(cone)
	cone.global_position = checkpoint.global_transform * local
	return cone


func test_barrier_across_the_lane_and_two_cones_set_it_up() -> void:
	_barrier(Vector3(0.3, 0, 0.2), deg_to_rad(15))
	_cone(Vector3(-1, 0, 4))
	_cone(Vector3(1, 0, 6))
	assert_true(checkpoint.is_set_up())


func test_barrier_along_the_lane_doesnt_close_it() -> void:
	_barrier(Vector3.ZERO, PI / 2)
	_cone(Vector3(-1, 0, 4))
	_cone(Vector3(1, 0, 6))
	assert_false(checkpoint.barrier_ok())
	assert_false(checkpoint.is_set_up())


func test_barrier_outside_the_box_doesnt_count() -> void:
	_barrier(Vector3(0, 0, 5))
	assert_false(checkpoint.barrier_ok())


func test_one_cone_or_cones_past_the_barrier_are_not_enough() -> void:
	_barrier(Vector3.ZERO)
	_cone(Vector3(0, 0, 4))
	_cone(Vector3(0, 0, -4))
	assert_false(checkpoint.cones_ok())
	assert_false(checkpoint.is_set_up())


func test_knocked_over_cone_doesnt_count() -> void:
	_barrier(Vector3.ZERO)
	_cone(Vector3(0, 0, 4))
	var fallen := _cone(Vector3(1, 0, 5))
	fallen.global_basis = Basis(Vector3.RIGHT, PI / 2)
	assert_false(checkpoint.cones_ok())


func test_it_tells_once_when_set_up() -> void:
	watch_signals(checkpoint)
	_barrier(Vector3.ZERO)
	_cone(Vector3(0, 0, 4))
	_cone(Vector3(0.5, 0, 7))
	await wait_physics_frames(3)
	assert_signal_emit_count(checkpoint, "set_up", 1)


func test_level_starts_with_the_kit_on_the_sidewalk_and_not_set_up() -> void:
	var level: TrafficControlLevel = (load("res://scenes/levels/traffic_control.tscn") as PackedScene).instantiate()
	add_child_autofree(level)
	await wait_physics_frames(2)
	# The fog check's lit cones (FogFlare) are cones too, but not the kit's.
	var kit := get_tree().get_nodes_in_group("traffic_cones").filter(func(cone: Node) -> bool:
		return not cone is FogFlare)
	assert_eq(kit.size(), TrafficControlLevel.CONES)
	assert_eq(get_tree().get_nodes_in_group("road_barriers").size(), 1)
	assert_false(level.checkpoint.is_set_up())
	# The checkpoint stands on the street in front of the station, not on a sidewalk.
	var at := level.checkpoint.global_position
	var street := CityLayout.street_z(CityLayout.place("station").block.y + 1)
	assert_almost_eq(at.z, street - CityLayout.STREET / 4, 0.01)
	assert_true(PlaceDraw.PLACES.has("traffic"))
