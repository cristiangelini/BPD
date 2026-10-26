extends GutTest

## The fog check online (control-neblina.md, step 6; docs/diseno/online.md): the host decides the queue, who La Bruma
## is and when every car brakes; every PC sees the same fog, the same headlights, the cars that run the checkpoint or
## bump into the one ahead, La Bruma's lamp and his horn at every corner when he runs off.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "fog"
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


## La Bruma's car, spawned on the host.
func _la_bruma(pcs: Array[Node]) -> QueueCar:
	var host := _level(pcs[0])
	host.queue.spawned = host.plan.wanted_index
	return host.queue.spawn()


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func test_both_pcs_play_the_same_fog() -> void:
	var pcs := await _on()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.plan.fog)
	assert_eq(guest.plan.wanted_index, host.plan.wanted_index)
	assert_eq(guest.plan.cars[guest.plan.wanted_index].fog, host.plan.cars[host.plan.wanted_index].fog, "same La Bruma")
	assert_true((guest.get_node("Environment") as WorldEnvironment).environment.fog_enabled, "the fog on the guest")
	assert_not_null(guest.get_node_or_null("FogHorn"))
	assert_not_null(guest.get_node_or_null("FogFlare0"))


func test_the_guest_sees_the_same_headlights() -> void:
	var pcs := await _on()
	var car := _la_bruma(pcs)
	var copy := await _copy(pcs, car)
	assert_true(copy.fog_mode)
	assert_eq(copy.fog, car.fog)
	assert_not_null(copy.get_node_or_null("Lamp"))
	assert_eq(FogCar.lit(copy, true), FogCar.lit(car, true))
	assert_eq(FogCar.lit(copy, false), FogCar.lit(car, false))


func test_a_car_running_the_checkpoint_on_the_host_shows_on_the_guest() -> void:
	var pcs := await _on()
	var car := _level(pcs[0]).queue.spawn()
	await _copy(pcs, car)
	_level(pcs[0]).queue.overran(car)
	var guest := _level(pcs[1]).queue
	await wait_until(func() -> bool: return guest.overruns == 1, 5.0)
	assert_eq(guest.overruns, 1)
	assert_eq(guest.sneaked, 1)


func test_a_bump_on_the_host_is_said_on_the_guest() -> void:
	var pcs := await _on()
	var car := _level(pcs[0]).queue.spawn()
	var copy := await _copy(pcs, car)
	car.bumped = true
	await wait_until(func() -> bool: return copy.bumped, 5.0)
	assert_true(copy.bumped)
	assert_eq(copy.saying(), tr(FogCar.bump_line(copy.plate)))


func test_cuffed_la_bruma_s_lamp_shows_on_the_guest() -> void:
	var pcs := await _on()
	var car := _la_bruma(pcs)
	await _copy(pcs, car)
	car.state = "waiting"
	car.speed = 0.0
	_case(pcs[0]).detain(car)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "LighthouseLamp", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "LighthouseLamp", true, false).size(), 1)


func test_la_bruma_runs_off_honking_on_the_guest_too() -> void:
	var pcs := await _on()
	var car := _la_bruma(pcs)
	await _copy(pcs, car)
	var horn: int = car.fog.horn
	_case(pcs[0]).queue.cars.erase(car)
	_case(pcs[0])._on_passed(car, false)
	var guest := _case(pcs[1])
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_not_null(guest.chase.truck.get_node_or_null("Lamp"), "his headlights on the guest's runaway")
	assert_eq(guest.chase.drops.fog_horn, horn)
	_case(pcs[0]).chase.drops.honk()
	await wait_until(func() -> bool: return guest.chase.drops.horn_bubble != null, 5.0)
	assert_not_null(guest.chase.drops.horn_bubble)
	assert_eq(guest.chase.drops.horn_bubble.text, tr(FogCar.horn_text(horn)))
