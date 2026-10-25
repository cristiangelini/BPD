extends GutTest

## The ghost car online (control-auto-fantasma.md, step 6; docs/diseno/online.md): the host decides the queue, which
## car is the ghost one, who drives it and when it pulls each prank; every PC sees the same ghost car with its antenna,
## the same pranks and the same tic at the pilot's window. A trunk opened from a guest makes it bolt on the host, the
## pilot cuffed on the host leaves his window on the guest and his remote reaches it, and in the chase the ghost car
## cutting in shows on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 2

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "ghost_car"
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> TrafficControlLevel:
	return OnlinePcs.level(net) as TrafficControlLevel


func _case(net: Node) -> TrafficCase:
	return _level(net).case


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	host.case.give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	var barrier := host.get_node("Barrier") as RoadBarrier
	barrier.freeze = true
	barrier.global_transform = host.checkpoint.global_transform
	return pcs


## The host's ghost car and its pilot's, stopped one behind the other at the barrier.
func _ghost_and_pilot(pcs: Array[Node]) -> Array[QueueCar]:
	var level := _level(pcs[0])
	var queue := level.queue
	queue.spawned = level.plan.ghost_index
	var ghost := queue.spawn()
	queue.spawned = level.plan.wanted_index
	var pilot := queue.spawn()
	for car in [ghost, pilot]:
		car.set_physics_process(false)
	for i in 300:
		ghost._physics_process(0.1)
		pilot._physics_process(0.1)
		if ghost.waiting() and pilot.waiting():
			break
	for car in [ghost, pilot]:
		car.set_physics_process(true)
	return [ghost, pilot]


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func test_both_pcs_play_the_ghost_car() -> void:
	var pcs := await _on()
	assert_true(_level(pcs[0]).plan.ghost)
	assert_true(_level(pcs[1]).plan.ghost)


func test_the_guest_sees_the_same_ghost_car_and_pilot() -> void:
	var pcs := await _on()
	var cars := _ghost_and_pilot(pcs)
	var ghost := await _copy(pcs, cars[0])
	var pilot := await _copy(pcs, cars[1])
	assert_true(ghost.ghost)
	assert_not_null(ghost.get_node_or_null("Antenna"))
	assert_null(ghost.get_node_or_null("WindowDriver"))
	assert_true(pilot.puppeteer)
	assert_eq(pilot.shirt, cars[1].shirt)
	assert_not_null(pilot.get_node_or_null("WindowDriver"))


func test_a_prank_on_the_host_plays_on_the_guest_with_the_tic() -> void:
	var pcs := await _on()
	var cars := _ghost_and_pilot(pcs)
	var ghost := await _copy(pcs, cars[0])
	var pilot := await _copy(pcs, cars[1])
	await wait_until(func() -> bool: return ghost.waiting() and pilot.waiting(), 5.0)
	var rig := ghost.get_node("Pilot") as GhostPilot
	var host_rig := cars[0].get_node("Pilot") as GhostPilot
	host_rig.prank("lights")
	await wait_until(func() -> bool: return rig.pranks == host_rig.pranks, 5.0)
	assert_eq(rig.last_prank, "lights")
	assert_true(rig.ticking())
	await wait_physics_frames(2)
	assert_true(GhostCar.remote_showing(pilot), "the tic shows on the guest")


func test_its_wheels_steer_on_the_guest_too() -> void:
	var pcs := await _on()
	var cars := _ghost_and_pilot(pcs)
	var ghost := await _copy(pcs, cars[0])
	var steer := {}
	for i in 30:
		await wait_physics_frames(2)
		steer[snappedf((ghost.get_node("Wheel0") as Node3D).rotation.y, 0.01)] = true
	assert_gt(steer.size(), 3)


func test_its_trunk_opened_from_the_guest_makes_it_bolt_on_the_host() -> void:
	var pcs := await _on()
	var cars := _ghost_and_pilot(pcs)
	var ghost := await _copy(pcs, cars[0])
	OnlinePcs.own_cop(pcs[1]).act("open_trunk", ghost)
	var host_rig := cars[0].get_node("Pilot") as GhostPilot
	await wait_until(func() -> bool: return host_rig.last_prank == "bolt", 5.0)
	assert_eq(host_rig.last_prank, "bolt")
	await wait_physics_frames(10)
	assert_eq((ghost.get_node("Pilot") as GhostPilot).pranks, host_rig.pranks, "not twice on the guest")


func test_the_pilot_cuffed_on_the_host_leaves_his_window_and_drops_his_remote_everywhere() -> void:
	var pcs := await _on()
	var cars := _ghost_and_pilot(pcs)
	var pilot := await _copy(pcs, cars[1])
	await wait_until(func() -> bool: return pilot.waiting(), 5.0)
	_case(pcs[0]).detain(cars[1])
	await wait_until(func() -> bool: return pilot.get_node_or_null("WindowDriver") == null, 5.0)
	assert_null(pilot.get_node_or_null("WindowDriver"))
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "RcRemote", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "RcRemote", true, false).size(), 1, "the remote reaches the guest")


func test_the_ghost_car_cutting_in_shows_on_the_guest() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var cars := _ghost_and_pilot(pcs)
	await _copy(pcs, cars[1])
	host.queue.cars.erase(cars[1])
	host._on_passed(cars[1], false)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.drops.ghost_look, host.chase.drops.ghost_look)
	host.chase.chasing = true
	host.patrol_car.global_position += Vector3(0, 0, 400)
	var ghost := host.chase.drops.cut_in()
	assert_not_null(ghost)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "ChaseGhost", true, false).size() > 0, 5.0)
	var copies := _level(pcs[1]).find_children("*", "ChaseGhost", true, false)
	assert_eq(copies.size(), 1)
	await wait_physics_frames(30)
	assert_lt((copies[0] as Node3D).global_position.distance_to(ghost.global_position), 1.5)
