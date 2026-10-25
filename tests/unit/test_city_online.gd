extends GutTest

## The living city online (ciudad-viva.md, step 11): the host's clock, rain, traffic and street events on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CITY_SCENE := preload("res://scenes/levels/city.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D: return CITY_SCENE.instantiate())


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _city(net: Node) -> City:
	return OnlinePcs.level(net) as City


func _walker(net: Node, index: int) -> CityWalker:
	return _city(net).get_node("Built/Traffic/Walker%d" % index)


func test_every_pc_names_the_traffic_the_same() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	await wait_physics_frames(2)
	var host_traffic: Array[Node3D] = pcs[0].city_sync.traffic()
	var guest_traffic: Array[Node3D] = pcs[1].city_sync.traffic()
	assert_gt(host_traffic.size(), 100)
	assert_eq(host_traffic.size(), guest_traffic.size())
	for i in [0, 10, host_traffic.size() - 1]:
		assert_eq(host_traffic[i].name, guest_traffic[i].name)


func test_only_the_host_starts_events() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	await wait_physics_frames(2)
	assert_true(_city(pcs[0]).events.director)
	assert_false(_city(pcs[1]).events.director, "the guest leaves it to the host")
	_city(pcs[1]).events.gap_left = 0.0
	await wait_physics_frames(3)
	assert_null(_city(pcs[1]).events.active)


func test_a_walker_the_host_moved_slides_there_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	await wait_physics_frames(2)
	var host_walker := _walker(pcs[0], 100)
	host_walker.stop_for(30.0)
	host_walker.position += Vector3(1.5, 0, 0)
	host_walker.say("EVENT_PURSE_HELP", 10.0)
	var guest_walker := _walker(pcs[1], 100)
	await wait_until(func() -> bool: return guest_walker.is_stopped(), 5.0)
	assert_true(guest_walker.is_stopped(), "stopped like the host's")
	await wait_seconds(1.5)
	assert_almost_eq(guest_walker.position.distance_to(host_walker.position), 0.0, 0.1, "where the host has them")
	assert_eq(guest_walker.saying(), "EVENT_PURSE_HELP", "and shouting the same")


func test_the_guest_has_the_hosts_hour_and_rain() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	await wait_physics_frames(2)
	var host := _city(pcs[0])
	host.clock.hour = 21.5
	host.rain.start = 5.0
	host.rain.length = 200.0
	host.rain.time = 50.0
	var guest := _city(pcs[1])
	await wait_until(func() -> bool: return absf(guest.clock.hour - host.clock.hour) < 0.05, 5.0)
	assert_almost_eq(guest.clock.hour, host.clock.hour, 0.05)
	assert_almost_eq(guest.rain.length, 200.0, 0.01)
	await wait_physics_frames(3)
	assert_gt(guest.rain.wet, 0.5, "raining there too")


func test_a_purse_snatch_shows_on_the_guest_and_the_cuffs_find_the_thief() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	await wait_physics_frames(2)
	var host_events := _city(pcs[0]).events
	assert_true(host_events.start_snatch(_walker(pcs[0], 100)))
	var path := NodePath(String(host_events.active.name) + "/Thief")
	var guest_events := _city(pcs[1]).events
	await wait_until(func() -> bool: return guest_events.get_node_or_null(path) != null, 5.0)
	var copy := guest_events.get_node_or_null(path)
	assert_is(copy, CityRunaway, "the thief's copy, at the same path")
	# The guest's cop cuffs the copy: the host's thief is caught and the host pays, on both PCs.
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("belt_cuff", guest_cop, [copy, copy.global_position])
	await wait_until(func() -> bool: return guest_events.earned == PurseSnatch.MONEY, 5.0)
	assert_eq(host_events.earned, PurseSnatch.MONEY, "the host paid")
	assert_eq(guest_events.earned, PurseSnatch.MONEY, "and the guest sees it")
