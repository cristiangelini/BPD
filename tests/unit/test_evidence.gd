extends GutTest

## Fragile evidence (docs/diseno/allanamiento.md, "La evidencia").

const TIN_SCENE := preload("res://scenes/props/cookie_tin.tscn")


func _floor() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 0.2, 20)
	shape.shape = box
	shape.position.y = -0.1
	floor_body.add_child(shape)
	add_child_autofree(floor_body)


func _tin(at: Vector3) -> Evidence:
	var tin: Evidence = TIN_SCENE.instantiate()
	tin.position = at
	add_child_autofree(tin)
	return tin


func test_cookie_tin_is_the_main_evidence() -> void:
	var tin := _tin(Vector3.ZERO)
	assert_eq(tin.full_value, 1000.0)
	assert_eq(tin.value, 1000.0)
	assert_eq(tin.mass, 3.0)


func test_soft_hit_costs_nothing() -> void:
	var tin := _tin(Vector3.ZERO)
	assert_eq(tin.hit(2.9), 0.0)
	assert_eq(tin.hit(3.0), 0.0)
	assert_eq(tin.value, 1000.0)


func test_hard_hit_costs_in_proportion() -> void:
	var tin := _tin(Vector3.ZERO)
	assert_almost_eq(tin.hit(5.0), 200.0, 0.01)
	assert_almost_eq(tin.hit(7.0), 400.0, 0.01)
	assert_almost_eq(tin.value, 400.0, 0.01)
	assert_false(tin.is_broken)


func test_breaks_at_zero_and_stops_losing() -> void:
	var tin := _tin(Vector3.ZERO)
	watch_signals(tin)
	tin.hit(20.0)
	assert_eq(tin.value, 0.0)
	assert_true(tin.is_broken)
	assert_signal_emitted(tin, "broken")
	assert_eq(tin.hit(20.0), 0.0)


func test_resting_on_the_floor_keeps_its_value() -> void:
	_floor()
	var tin := _tin(Vector3(0, 0.2, 0))
	await wait_physics_frames(120)
	assert_eq(tin.value, 1000.0)


func test_dropping_it_from_high_up_damages_it() -> void:
	_floor()
	var tin := _tin(Vector3(0, 3.0, 0))
	await wait_physics_frames(120)
	assert_lt(tin.value, 1000.0)
	assert_gt(tin.value, 0.0)
