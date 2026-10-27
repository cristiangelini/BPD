extends GutTest

## The elevator of the Las Palomas building (docs/diseno/edificio.md, step 2): between the lobby and floor 30 in 15 s,
## 400 kg at most, stuck every 4 trips unless someone jumps, and the doors open only where it stands.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")

var tower: ApartmentTower
var elevator: TowerElevator
var cop: Cop


func before_each() -> void:
	tower = TOWER_SCENE.instantiate()
	cop = tower.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(tower)
	await wait_physics_frames(2)
	elevator = tower.elevator


func after_each() -> void:
	Engine.time_scale = 1.0


func _shut(y: float) -> bool:
	var from := tower.to_global(Vector3(0, y + 1.0, -3.0))
	var query := PhysicsRayQueryParameters3D.create(from, tower.to_global(Vector3(0, y + 1.0, -4.6)), 1)
	return not tower.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _into_car() -> void:
	cop.global_position = elevator.to_global(Vector3(0, 0.1, -0.2))
	await _stand(4)


## The cop stands still (or jumps) for `frames` physics frames: without input it only moves through step().
func _stand(frames: int, jump := false) -> void:
	for i in frames:
		cop.step(get_physics_process_delta_time(), Vector2.ZERO, false, false, jump)
		await wait_physics_frames(1)


func test_it_waits_open_at_the_lobby_and_shut_up_there() -> void:
	await wait_seconds(TowerElevator.DOOR_TIME + 0.2)
	assert_true(elevator.is_open())
	assert_false(_shut(ApartmentTower.LOBBY_Y), "the lobby's doors are open")
	assert_true(_shut(ApartmentTower.TOP_Y), "floor 30's are shut")
	assert_eq(elevator.current_floor(), 0)
	assert_eq(elevator.prompt_key(cop), "PROMPT_ELEVATOR_UP")


func test_a_cop_rides_up_to_floor_30() -> void:
	await _into_car()
	assert_eq(elevator.load_kg(), TowerElevator.COP_KG, "a cop weighs 80")
	watch_signals(elevator)
	elevator.use(cop)
	assert_true(elevator.moving)
	Engine.time_scale = 3.0
	await _stand(30)
	assert_true(_shut(ApartmentTower.LOBBY_Y), "the doors shut behind")
	while elevator.moving:
		await _stand(10)
	assert_signal_emitted_with_parameters(elevator, "arrived", [1])
	assert_eq(elevator.current_floor(), ApartmentTower.FLOORS)
	assert_gt(tower.to_local(cop.global_position).y, ApartmentTower.TOP_Y - 0.3, "the cop came along")
	await wait_seconds(TowerElevator.DOOR_TIME)
	assert_false(_shut(ApartmentTower.TOP_Y), "and the doors open on floor 30")
	assert_eq(elevator.prompt_key(cop), "PROMPT_ELEVATOR_DOWN")


func test_over_400_kg_it_buzzes() -> void:
	var weight := RigidBody3D.new()
	weight.mass = 350.0
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	weight.add_child(shape)
	tower.add_child(weight)
	weight.global_position = elevator.to_global(Vector3(0.4, 0.6, -0.4))
	await _into_car()
	assert_gt(elevator.load_kg(), TowerElevator.MAX_KG)
	watch_signals(elevator)
	elevator.use(cop)
	assert_false(elevator.moving)
	assert_signal_emitted(elevator, "overloaded")


func test_the_call_button_brings_it() -> void:
	elevator.call_to(1)
	elevator._t = 0.999
	await wait_until(func() -> bool: return not elevator.moving, 2.0)
	assert_eq(elevator.at_stop, 1)
	assert_eq(tower.calls[0].prompt_key(cop), "PROMPT_CALL_ELEVATOR")
	tower.calls[0].use(cop)
	assert_true(elevator.moving, "back down to whoever calls from the lobby")


func test_every_fourth_trip_it_gets_stuck_until_someone_jumps() -> void:
	await _into_car()
	elevator.trips = TowerElevator.JAM_EVERY - 1
	watch_signals(elevator)
	elevator.send(1)
	Engine.time_scale = 3.0
	while elevator.jammed_left <= 0.0 and elevator.moving:
		await _stand(5)
	assert_signal_emitted(elevator, "jammed")
	assert_almost_eq(elevator.position.y, ApartmentTower.TOP_Y / 2, 1.0, "halfway up")
	var stuck_at := elevator.position.y
	await _stand(10)
	assert_eq(elevator.position.y, stuck_at, "stuck between floors")
	await _stand(1, true)
	await _stand(3)
	assert_eq(elevator.jammed_left, 0.0, "a jump unjams it")
	await _stand(3)
	assert_gt(elevator.position.y, stuck_at)
