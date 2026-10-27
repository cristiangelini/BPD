extends GutTest

## The hanging scaffold of the Las Palomas building (docs/diseno/edificio.md, step 3): from 30B's balcony to the street
## in 40 s with two buttons, swinging with the wind up high, leaning toward its load, and what falls is lost and a fine.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")

var tower: ApartmentTower
var scaffold: HangingScaffold
var cop: Cop


func before_each() -> void:
	tower = TOWER_SCENE.instantiate()
	cop = tower.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(tower)
	await wait_physics_frames(2)
	scaffold = tower.scaffold
	scaffold.wind = 0.0


func after_each() -> void:
	Engine.time_scale = 1.0


func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(tower.to_global(from), tower.to_global(to), 1)
	return tower.get_world_3d().direct_space_state.intersect_ray(query)


func _box(at: Vector3, kg: float, size: float) -> RigidBody3D:
	var box := RigidBody3D.new()
	box.mass = kg
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3.ONE * size
	shape.shape = box_shape
	box.add_child(shape)
	box.position = at
	tower.add_child(box)
	return box


## The cop stands still for `frames` physics frames: without input it only moves through step().
func _stand(frames: int) -> void:
	for i in frames:
		cop.step(get_physics_process_delta_time(), Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)


func test_it_waits_docked_at_the_balcony_gap() -> void:
	assert_eq(scaffold.at_stop, 1)
	assert_almost_eq(scaffold.position.y, ApartmentTower.TOP_Y, 0.001, "its deck level with the balcony")
	var y := ApartmentTower.TOP_Y + 0.7
	var balcony := ApartmentTower.HALF_Z + 0.8
	var x := ApartmentTower.SCAFFOLD_X
	assert_true(_ray(Vector3(x, y, balcony), Vector3(x, y, ApartmentTower.SCAFFOLD_Z)).is_empty(), "walk on through the gap")
	assert_false(_ray(Vector3(x - 2.5, y, balcony), Vector3(x - 2.5, y, ApartmentTower.SCAFFOLD_Z)).is_empty(),
		"the rail beside the gap")
	var deck := _ray(Vector3(x, y, ApartmentTower.SCAFFOLD_Z), Vector3(x, y - 2.0, ApartmentTower.SCAFFOLD_Z))
	assert_eq(deck.get("collider"), scaffold, "standing on its deck")


func test_forty_seconds_from_end_to_end() -> void:
	watch_signals(scaffold)
	var down: ScaffoldButton = scaffold.buttons[0]
	var up: ScaffoldButton = scaffold.buttons[1]
	assert_eq(down.prompt_key(cop), "PROMPT_SCAFFOLD_DOWN")
	assert_eq(up.prompt_key(cop), "", "already at the top")
	down.use(cop)
	assert_eq(down.prompt_key(cop), "PROMPT_SCAFFOLD_STOP")
	await wait_seconds(1.0)
	var speed := (ApartmentTower.TOP_Y - ApartmentTower.STREET_Y) / HangingScaffold.TRAVEL_TIME
	assert_almost_eq(ApartmentTower.TOP_Y - scaffold.position.y, speed, 0.25, "about 2.4 m a second")
	down.use(cop)
	assert_false(scaffold.moving(), "the same button again stops it")
	var stopped_at := scaffold.deck_y
	await wait_physics_frames(10)
	assert_eq(scaffold.deck_y, stopped_at, "it hangs where it stopped")
	scaffold.deck_y = ApartmentTower.STREET_Y + 1.0
	down.use(cop)
	await wait_seconds(0.8)
	assert_eq(scaffold.deck_y, ApartmentTower.STREET_Y, "down at the street")
	assert_eq(scaffold.at_stop, 0)
	assert_signal_emitted_with_parameters(scaffold, "arrived", [0])
	assert_eq(tower.scaffold_calls[0].prompt_key(cop), "PROMPT_CALL_SCAFFOLD", "floor 30 can call it back")
	assert_eq(tower.scaffold_calls[1].prompt_key(cop), "", "it's already at the street")
	tower.scaffold_calls[0].use(cop)
	assert_eq(scaffold.direction, 1, "on its way up")


func test_a_cop_rides_it_down() -> void:
	cop.global_position = scaffold.to_global(Vector3(0, 0.1, 0))
	await _stand(4)
	assert_eq(scaffold.load_center().y, TowerElevator.COP_KG, "a cop on it")
	scaffold.press(-1)
	await _stand(60)
	assert_lt(cop.global_position.y, tower.to_global(Vector3(0, ApartmentTower.TOP_Y - 1.5, 0)).y, "going down with it")
	assert_almost_eq(cop.global_position.y, scaffold.global_position.y, 0.3, "still standing on it")
	assert_true(tower.dropped.is_empty(), "riding down isn't falling")


func test_the_wind_swings_it_up_high_and_not_at_the_street() -> void:
	scaffold.wind = 1.0
	scaffold.rng.seed = 7
	var highest := 0.0
	for i in 300:
		await wait_physics_frames(1)
		highest = maxf(highest, absf(scaffold.tilt.x))
	assert_gt(highest, 0.03, "it swings up at floor 30")
	scaffold.deck_y = ApartmentTower.STREET_Y
	scaffold.at_stop = 0
	scaffold.tilt = Vector2.ZERO
	scaffold.spin = Vector2.ZERO
	for i in 300:
		await wait_physics_frames(1)
	assert_almost_eq(scaffold.tilt.x, 0.0, 0.001, "no wind down at the street")


func test_a_body_landing_on_it_swings_it() -> void:
	_box(scaffold.position + Vector3(0, 2.5, 0.4), 60.0, 0.4)
	await wait_seconds(1.0)
	assert_gt(absf(scaffold.spin.x) + absf(scaffold.tilt.x), 0.01, "the hit rocks it")


func test_it_leans_toward_its_load_and_the_loose_box_slides_off() -> void:
	_box(scaffold.position + Vector3(HangingScaffold.SIZE.x / 2 - 0.5, 0.3, 0), 300.0, 0.5)
	var loose := _box(scaffold.position + Vector3(1.5, 0.12, 0.42), 5.0, 0.2)
	await wait_seconds(4.0)
	assert_lt(scaffold.tilt.y, -0.2, "the heavy end goes down")
	assert_lt(loose.position.y, ApartmentTower.TOP_Y - 3.0, "the loose box slid under the rail and fell")
	await wait_seconds(1.5)
	assert_true(tower.dropped.has(loose), "lost")
	assert_eq(tower.fines, ApartmentTower.DROP_FINE)


func test_evidence_that_falls_from_up_high_is_lost() -> void:
	var evidence := Evidence.new()
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3.ONE * 0.4
	shape.shape = box_shape
	evidence.add_child(shape)
	evidence.position = Vector3(ApartmentTower.SCAFFOLD_X, ApartmentTower.TOP_Y + 1.0, ApartmentTower.SCAFFOLD_Z + 1.5)
	tower.add_child(evidence)
	watch_signals(tower)
	await wait_seconds(1.6)
	assert_true(tower.dropped.has(evidence))
	assert_true(evidence.is_broken, "nothing survives 96 m")
	assert_eq(evidence.value, 0.0)
	assert_eq(tower.fines, ApartmentTower.DROP_FINE)
	assert_signal_emitted(tower, "something_fell", "Don Evaristo will see it")
