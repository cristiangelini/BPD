extends GutTest

## The street race check online (control-carrera.md, step 6; docs/diseno/online.md): the host decides the queue, the
## heats, when they launch and who El Turbo is; every PC sees the same racers, the strips unrolled or rolled up, the
## flat tires, El Turbo's trophy and his racer when he runs off.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "race"
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


## El Turbo's heat on the host, and El Turbo.
func _turbo_heat(pcs: Array[Node]) -> QueueCar:
	var host := _level(pcs[0])
	host.queue.heats = host.plan.turbo_heat
	var heat := host.queue.spawn_heat()
	return heat[host.plan.turbo_slot]


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func test_both_pcs_play_the_same_race() -> void:
	var pcs := await _on()
	var host := _level(pcs[0]).plan
	var guest := _level(pcs[1]).plan
	assert_true(guest.race)
	assert_eq(guest.turbo_heat, host.turbo_heat)
	assert_eq(guest.turbo().race, host.turbo().race, "the same El Turbo")
	assert_eq(_level(pcs[1]).spike_strips.size(), _level(pcs[0]).spike_strips.size(), "strips on every PC")


func test_the_guest_sees_the_same_racers_rev() -> void:
	var pcs := await _on()
	var turbo := _turbo_heat(pcs)
	var copy := await _copy(pcs, turbo)
	assert_true(copy.racer)
	assert_eq(copy.race, turbo.race)
	assert_eq(copy.race_slot, turbo.race_slot)
	assert_eq(copy.get_node("Roundel/Number").text, str(turbo.race.number))
	await wait_until(func() -> bool: return copy.state == "revving", 10.0)
	assert_eq(copy.saying(), tr(RaceCar.rev_line(copy.plate)), "it roars on the guest too")


func test_a_flat_on_the_host_is_flat_on_the_guest() -> void:
	var pcs := await _on()
	var turbo := _turbo_heat(pcs)
	var copy := await _copy(pcs, turbo)
	turbo.state = "racing"
	turbo.speed = RaceCar.SPEED
	turbo.puncture()
	await wait_until(func() -> bool: return copy.flat, 5.0)
	assert_true(copy.flat)
	assert_almost_eq((copy.get_node("Wheel0") as Node3D).scale.y, QueueCar.FLAT_SQUASH, 0.01)
	await wait_until(func() -> bool: return _case(pcs[1]).racer_fines == 1, 5.0)
	assert_eq(_case(pcs[1]).racer_fines, 1, "the guest's pay counts it too")


func test_a_strip_unrolled_on_the_host_shows_unrolled_on_the_guest() -> void:
	var pcs := await _on()
	var strip := _level(pcs[0]).spike_strips[0]
	var copy := _level(pcs[1]).spike_strips[0]
	strip.deploy()
	await wait_until(func() -> bool: return copy.deployed, 5.0)
	assert_true(copy.deployed)
	strip.roll_up()
	await wait_until(func() -> bool: return not copy.deployed, 5.0)
	assert_false(copy.deployed)


func test_el_turbo_s_trophy_and_his_racer_reach_the_guest() -> void:
	var pcs := await _on()
	var turbo := _turbo_heat(pcs)
	await _copy(pcs, turbo)
	_case(pcs[0])._on_passed(turbo, false)
	var guest := _case(pcs[1])
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.chase.truck.racer)
	assert_true(guest.chase.drops.race)
	assert_not_null(guest.chase.truck.get_node_or_null("Exhaust"), "the guest's runaway is his racer too")


func test_cuffed_el_turbo_s_trophy_shows_on_the_guest() -> void:
	var pcs := await _on()
	var turbo := _turbo_heat(pcs)
	await _copy(pcs, turbo)
	turbo.state = "punctured"
	turbo.speed = 0.0
	_case(pcs[0]).detain(turbo)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "RaceTrophy", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "RaceTrophy", true, false).size(), 1)
