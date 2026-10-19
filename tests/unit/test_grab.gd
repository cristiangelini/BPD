extends GutTest

## Grabbing, carrying together and throwing (docs/diseno/escala.md, "Agarrar y cargar").

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")
const SAFE_SCENE := preload("res://scenes/props/heavy_safe.tscn")


func before_each() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(50, 0.2, 50)
	shape.shape = box
	shape.position.y = -0.1
	floor_body.add_child(shape)
	add_child_autofree(floor_body)


func _spawn(scene: PackedScene, at: Vector3) -> Grabbable:
	var prop: Grabbable = scene.instantiate()
	prop.position = at
	add_child_autofree(prop)
	return prop


## Holds the prop at a point 1.4 m up for the given holders and returns how high it got.
func _lift(prop: Grabbable, holder_count: int, seconds := 2.0) -> float:
	var target := prop.global_position + Vector3.UP * 1.4
	var top := prop.global_position.y
	for frame in int(seconds * 60):
		for id in holder_count:
			prop.hold(id + 1, target)
		await wait_physics_frames(1)
		top = maxf(top, prop.global_position.y)
	return top


func test_one_cop_lifts_a_crate() -> void:
	var crate := _spawn(CRATE_SCENE, Vector3(0, 0.25, 0))
	var top := await _lift(crate, 1)
	assert_gt(top, 1.4, "a 3 kg crate should reach the hold point")


func test_one_cop_cannot_lift_the_safe() -> void:
	var safe := _spawn(SAFE_SCENE, Vector3(0, 0.3, 0))
	var top := await _lift(safe, 1)
	assert_lt(top, 0.5, "40 kg is more than one cop can carry")


func test_two_cops_lift_the_safe() -> void:
	var safe := _spawn(SAFE_SCENE, Vector3(0, 0.3, 0))
	var top := await _lift(safe, 2)
	assert_gt(top, 1.2, "two cops together carry 40 kg")


func test_letting_go_drops_it() -> void:
	var crate := _spawn(CRATE_SCENE, Vector3(0, 0.25, 0))
	await _lift(crate, 1, 1.0)
	crate.let_go(1)
	await wait_physics_frames(90)
	assert_lt(crate.global_position.y, 0.4)


func test_throw_speed_depends_on_mass() -> void:
	assert_almost_eq(Grabbable.throw_speed(1.0), GameScale.THROW_SPEED_1KG, 0.001)
	assert_almost_eq(Grabbable.throw_speed(0.2), GameScale.THROW_SPEED_1KG, 0.001)
	assert_lt(Grabbable.throw_speed(4.0), Grabbable.throw_speed(1.0))


func test_cop_grabs_what_it_looks_at_within_reach() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.input_enabled = false
	var near := _spawn(CRATE_SCENE, Vector3(0, GameScale.EYE_HEIGHT, -1.5))
	near.freeze = true
	await wait_physics_frames(2)
	assert_true(grabber.try_grab(), "crate 1.5 m ahead is within reach")
	assert_eq(grabber.held, near)
	grabber.release()
	assert_false(near.is_held())


func test_cop_cannot_grab_beyond_reach() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.input_enabled = false
	var far := _spawn(CRATE_SCENE, Vector3(0, GameScale.EYE_HEIGHT, -4.0))
	far.freeze = true
	await wait_physics_frames(2)
	assert_false(grabber.try_grab())
