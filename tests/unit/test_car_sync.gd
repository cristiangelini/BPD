extends GutTest

## The patrol car online (docs/diseno/online.md, step 4): getting in and out happens on every PC, the host simulates
## the car and a guest at the wheel sends it the controls.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CAR := preload("res://scenes/vehicles/patrol_car.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, _fill_level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _fill_level(level: Node3D) -> void:
	var floor := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(200, 1, 200)
	shape.shape = box
	floor.add_child(shape)
	floor.position = Vector3(0, -0.5, 0)
	level.add_child(floor)
	var car: PatrolCar = CAR.instantiate()
	car.name = "Car"
	car.position = Vector3(0, 0.5, -6)
	level.add_child(car)


func _car(net: Node) -> PatrolCar:
	return OnlinePcs.level(net).get_node("Car")


func test_the_guest_takes_the_wheel_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy_on_host: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	guest_cop.global_position = _car(pcs[1]).to_global(Vector3(1.8, 0, 0.6))
	guest_cop.act("use", _car(pcs[1]), _car(pcs[1]).use_args(guest_cop))
	await wait_until(func() -> bool: return _car(pcs[0]).driver() == copy_on_host, 5.0)
	assert_eq(_car(pcs[1]).driver(), guest_cop, "the guest drives on its own PC")
	assert_eq(_car(pcs[0]).driver(), copy_on_host, "and on the host's")
	assert_true(_car(pcs[1]).freeze, "the guest's car is a copy the host moves")


func test_the_host_drives_the_car_with_the_guest_controls() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.global_position = _car(pcs[1]).to_global(Vector3(1.8, 0, 0.6))
	await wait_physics_frames(30)
	guest_cop.act("use", _car(pcs[1]), _car(pcs[1]).use_args(guest_cop))
	await wait_until(func() -> bool: return _car(pcs[0]).driver() != null, 5.0)
	var start := _car(pcs[0]).global_position
	for i in 90:
		guest_cop.sync.send_controls(1.0, 0.0, false)
		await wait_physics_frames(1)
	var on_host := _car(pcs[0])
	assert_gt(on_host.global_position.distance_to(start), 1.0, "the host's car moved forward")
	for i in 60:
		guest_cop.sync.send_controls(0.0, 0.0, true)
		await wait_physics_frames(1)
	await wait_until(func() -> bool: return _car(pcs[1]).global_position.distance_to(on_host.global_position) < 0.3, 5.0)
	assert_lt(_car(pcs[1]).global_position.distance_to(on_host.global_position), 0.3, "the guest sees it there")


func test_the_siren_turns_on_for_everyone() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	OnlinePcs.own_cop(pcs[1]).act("toggle_siren", _car(pcs[1]))
	await wait_until(func() -> bool: return _car(pcs[1]).siren_on, 5.0)
	assert_true(_car(pcs[0]).siren_on)
