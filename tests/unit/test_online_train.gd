extends GutTest

## The train online (escena-tren.md, step 6; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' train follows the host's clock and brake, the seats and stickers, the tickets, the cart, the clues and the
## getaway on the roofs.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/train.tscn")

var _pcs: OnlinePcs


## A seed whose culprit runs off when accused.
static func _running_seed() -> int:
	for seed_value in range(1, 400):
		if hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
			return seed_value
	return -1


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrainLevel = LEVEL_SCENE.instantiate()
		level.case_seed = _running_seed()
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _train(net: Node) -> Train:
	return (OnlinePcs.level(net) as TrainLevel).train


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as TrainLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as TrainLevel).case.tip_given, 5.0)
	return pcs


func test_the_train_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "train")
	assert_true(PlaceDraw.PLACES.has("train"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("train"), "the train comes up")


func test_the_clock_the_brake_the_seats_and_the_stickers_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _train(pcs[0])
	var guest := _train(pcs[1])
	assert_true(guest.case.follower)
	host.ride.time = 30.0
	host.pull_brake()
	host.seat(0, 5)
	host.seat(5, 0)
	host.stick_sticker(2, host.magicians[3])
	await wait_until(func() -> bool: return guest.sticker_of(3) == 2, 5.0)
	assert_eq(guest.sticker_of(3), 2, "the sticker on the same magician")
	assert_eq(guest.brake_pulls, 1)
	assert_gt(guest.brake_left, 0.0, "braked there too")
	assert_almost_eq(guest.ride.time, 30.0, 0.01, "the stations' clock waits there too")
	assert_eq(guest.seat_of, host.seat_of, "the same seats")
	assert_almost_eq(guest.magicians[0].position, host.magicians[0].position, Vector3.ONE * 0.01)
	host.drop_sticker(host.magicians[3])
	await wait_until(func() -> bool: return guest.sticker_of(3) < 0, 5.0)
	assert_eq(guest.sticker_of(3), -1, "peeled off there too")
	assert_not_null(guest.get_node_or_null("Sticker2"), "and lying on the floor")


func test_the_cart_the_window_and_the_knot_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _train(pcs[0])
	var guest := _train(pcs[1])
	host.cart.position += Vector3(2, 0, 0)
	host.clues.window.set_open(true)
	host.clues.knot.untie()
	host.clues.showcase.touched = true
	host.tickets["Cop"] = true
	await wait_until(func() -> bool: return guest.clues.knot.untied, 5.0)
	assert_true(guest.clues.knot.untied)
	assert_true(guest.clues.window.open)
	assert_true(guest.clues.showcase.touched)
	assert_true(guest.tickets.has("Cop"))
	assert_almost_eq(guest.cart.position, host.cart.position, Vector3.ONE * 0.01)


func test_the_getaway_on_the_roofs_reaches_the_guest() -> void:
	var pcs := await _on()
	var host := _train(pcs[0])
	var guest := _train(pcs[1])
	var case := (OnlinePcs.level(pcs[0]) as TrainLevel).case
	host.stick_sticker(0, host.magicians[case.plan.culprit])
	case.accuse(0)
	assert_not_null(host.roof_chase)
	await wait_until(func() -> bool: return guest.roof_chase != null, 5.0)
	assert_not_null(guest.roof_chase, "he runs on the guest's roofs too")
	assert_true(guest.roof_chase.follower)
	await wait_until(func() -> bool: return absf(guest.roof_chase.runner.position.x
		- host.roof_chase.runner.position.x) < 0.3, 5.0)
	assert_almost_eq(guest.roof_chase.runner.position.y, TrainRoofChase.ROOF_Y, 0.01)
	host.roof_chase.runner.position.x = TrainRoofChase.END_X - 0.01
	var guest_case := (OnlinePcs.level(pcs[1]) as TrainLevel).case
	await wait_until(func() -> bool: return guest.roof_chase.done and guest_case.escaped, 5.0)
	assert_true(guest.roof_chase.done)
	assert_false(guest.roof_chase.runner.visible, "into the river there too")
	assert_true(guest_case.escaped)
