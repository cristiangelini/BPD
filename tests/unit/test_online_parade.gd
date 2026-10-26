extends GutTest

## The parade online (control-desfile.md, step 6; docs/diseno/online.md): the host decides the queue, who El Antifaz
## is, when a float's music stops and which dancers are down; every PC sees the same floats and dancers, the boo, the
## dancers down, El Antifaz gone from his float and the crown, and his float shooting confetti when he runs off.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "parade"
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


## The plan's `index`th car, spawned on the host.
func _spawn(pcs: Array[Node], index: int) -> QueueCar:
	var host := _level(pcs[0])
	host.queue.spawned = index
	return host.queue.spawn()


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func _thief(car: QueueCar) -> ParadeDancer:
	return ParadeFloat.dancers_of(car)[int(car.parade.thief)]


func test_both_pcs_play_the_same_parade() -> void:
	var pcs := await _on()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.plan.parade)
	assert_eq(guest.plan.wanted_index, host.plan.wanted_index)
	assert_eq(guest.plan.cars[guest.plan.wanted_index].parade, host.plan.cars[host.plan.wanted_index].parade)
	var car := _spawn(pcs, host.plan.wanted_index)
	var copy := await _copy(pcs, car)
	assert_eq(copy.parade, car.parade)
	assert_eq(ParadeFloat.dancers_of(copy).size(), ParadeFloat.dancers_of(car).size())
	assert_true(_thief(copy).thief, "El Antifaz is the same dancer on the guest")


func test_the_host_s_music_cut_boos_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	var copy := await _copy(pcs, car)
	car.music_cut = true
	car.state = "waiting"
	car.speed = 0.0
	car.set_physics_process(false)
	await wait_until(func() -> bool: return copy.music_cut, 5.0)
	assert_true(copy.music_cut)
	await wait_frames(3)
	assert_eq((copy.get_node("Notes") as Label3D).text, tr("PARADE_BOO"))


func test_a_dancer_down_on_the_host_is_down_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	var copy := await _copy(pcs, car)
	var i := (int(car.parade.thief) + 1) % ParadeFloat.dancers_of(car).size()
	ParadeFloat.dancers_of(car)[i].go_down()
	await wait_until(func() -> bool: return ParadeFloat.dancers_of(copy)[i].is_down, 5.0)
	assert_true(ParadeFloat.dancers_of(copy)[i].is_down)
	assert_eq(_case(pcs[1]).innocents, 0, "only the host counts complaints")
	ParadeFloat.dancers_of(car)[i].climb_back()
	await wait_until(func() -> bool: return not ParadeFloat.dancers_of(copy)[i].is_down, 5.0)
	assert_false(ParadeFloat.dancers_of(copy)[i].is_down, "back on the float")


func test_cuffed_el_antifaz_leaves_his_float_and_the_crown_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	var copy := await _copy(pcs, car)
	car.state = "waiting"
	car.speed = 0.0
	var thief := _thief(car)
	thief.go_down()
	_case(pcs[0]).detain_dancer(thief)
	assert_not_null(_case(pcs[0]).suspect)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "ParadeCrown", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "ParadeCrown", true, false).size(), 1)
	await wait_until(func() -> bool:
		return not ParadeFloat.dancers_of(copy).any(func(d: ParadeDancer) -> bool: return d.thief), 5.0)
	assert_false(ParadeFloat.dancers_of(copy).any(func(d: ParadeDancer) -> bool: return d.thief),
		"off his float on the guest too")


func test_he_runs_off_shooting_confetti_on_the_guest_too() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	await _copy(pcs, car)
	_case(pcs[0]).queue.cars.erase(car)
	_case(pcs[0])._on_passed(car, false)
	var guest := _case(pcs[1])
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.suspect_id, SuspectCar.PARADE_FLOAT)
	assert_not_null(guest.chase.truck.get_node_or_null("Theme"), "his float, dressed")
	assert_true(guest.chase.drops.confetti)
	_case(pcs[0]).chase.drops.shoot_confetti()
	await wait_until(func() -> bool: return guest.chase.drops.clouds.size() == 1, 5.0)
	assert_eq(guest.chase.drops.clouds.size(), 1)
