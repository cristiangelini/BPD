extends GutTest

## The airport online (politico-aeropuerto.md, step 7; docs/diseno/online.md): the host's airport runs the belt, the
## clock, the deputy and the porter, and every PC sees the same clock, X-ray, clues, end and getaway.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const AIRPORT_SCENE := preload("res://scenes/levels/airport.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var airport: Airport = AIRPORT_SCENE.instantiate()
		airport.case_seed = SEED
		airport.get_node("Cop/Grabber").input_enabled = false
		return airport)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _airport(net: Node) -> Airport:
	return OnlinePcs.level(net) as Airport


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _airport(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.belt.follower, "the guest's belt only shows the host's")
	assert_true(guest.boarding.follower)
	assert_true(guest.deputy.follower)
	assert_true(OddCargo.of(guest.odd).follower)
	assert_true(guest.porter.follower)
	assert_false(_airport(pcs[0]).case.follower)


func test_the_clock_and_the_deputy_off_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _airport(pcs[0])
	var guest := _airport(pcs[1])
	host.belt.start()
	host.deputy.wander()
	await wait_until(func() -> bool: return guest.boarding.running and guest.belt.running \
		and guest.deputy.state == AirportDeputy.State.WALKING, 5.0)
	assert_true(guest.boarding.running)
	assert_lt(guest.boarding.left, AirportBoarding.BOARDING + 0.01)
	assert_eq(guest.deputy.state, AirportDeputy.State.WALKING)


func test_the_x_ray_and_the_scandal_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _airport(pcs[0])
	var guest := _airport(pcs[1])
	host.xray.scan(host.odd)
	await wait_until(func() -> bool: return guest.case.scandal and guest.xray.caption() != "", 5.0)
	assert_true(guest.case.scandal)
	assert_eq(guest.xray.caption(), host.xray.caption())


func test_a_cuffed_porter_and_the_clues_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _airport(pcs[0])
	var guest := _airport(pcs[1])
	host.porter.use(host.get_node("Cop"))
	host.porter.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.porter.is_cuffed() and guest.case.clues.size() == 1, 5.0)
	assert_true(guest.porter.is_cuffed())
	assert_eq(guest.case.clues, ["keychain"])


func test_the_boarding_the_getaway_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _airport(pcs[0])
	var guest := _airport(pcs[1])
	host.politician.global_position = host.to_global(Vector3(14, Airport.FLOOR_TOP, 4))
	host.boarding.close()
	await wait_until(func() -> bool: return guest.case.chase != null and guest.boarding.done, 5.0)
	assert_not_null(guest.case.chase, "the porter drives off there too")
	assert_false(guest.porter.visible)
	assert_true(guest.case.boarded)
	host.case.chase.ended.emit(true)
	await wait_until(func() -> bool: return guest.case.shift_over, AirportCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
	assert_true(guest.case.porter_detained())
