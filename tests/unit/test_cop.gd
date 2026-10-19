extends GutTest

## Cop movement on a flat floor, driven tick by tick without real input.

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TICK := 1.0 / 60.0

var _cop: Cop


func before_each() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(200, 0.2, 200)
	shape.shape = box
	shape.position.y = -0.1
	floor_body.add_child(shape)
	add_child_autofree(floor_body)
	_cop = COP_SCENE.instantiate()
	_cop.input_enabled = false
	add_child_autofree(_cop)
	await _settle()


func _settle() -> void:
	for i in 10:
		_cop.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)


func _walk(seconds: float, run := false, crouch := false) -> float:
	var start := _cop.global_position
	for i in int(seconds / TICK):
		_cop.step(TICK, Vector2(0, -1), run, crouch, false)
		await wait_physics_frames(1)
	return start.distance_to(_cop.global_position)


func test_camera_at_eye_height() -> void:
	assert_almost_eq(_cop.camera.global_position.y, GameScale.EYE_HEIGHT, 0.05)


func test_walk_speed() -> void:
	var meters := await _walk(1.0)
	assert_almost_eq(meters, GameScale.WALK_SPEED, 0.3)


func test_run_is_faster_and_spends_stamina() -> void:
	var meters := await _walk(1.0, true)
	assert_almost_eq(meters, GameScale.RUN_SPEED, 0.4)
	assert_lt(_cop.stamina, GameScale.RUN_STAMINA)


func test_run_stops_when_stamina_runs_out() -> void:
	_cop.stamina = 0.0
	var meters := await _walk(0.5, true)
	assert_almost_eq(meters, GameScale.WALK_SPEED * 0.5, 0.3)


func test_crouch_lowers_camera_and_speed() -> void:
	var meters := await _walk(1.0, false, true)
	assert_true(_cop.is_crouching)
	assert_almost_eq(meters, GameScale.CROUCH_SPEED, 0.3)
	assert_lt(_cop.camera.global_position.y, GameScale.CROUCH_HEIGHT)


func test_jump_height() -> void:
	_cop.step(TICK, Vector2.ZERO, false, false, true)
	var top := 0.0
	for i in 90:
		await wait_physics_frames(1)
		_cop.step(TICK, Vector2.ZERO, false, false, false)
		top = maxf(top, _cop.global_position.y)
	assert_almost_eq(top, GameScale.JUMP_HEIGHT, 0.15)
