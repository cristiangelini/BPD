extends GutTest

## The pizzeria raid online (allanamiento-pizzeria.md, step 7): Don Muzza is run by the host and followed by the
## guests, the counter's phone works from any PC, and what each story's rig decides on the host (the dough's size, the
## oven put out, the phones ringing, the giant pizza swung open) happens on every guest.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const PIZZERIA := preload("res://scenes/levels/pizza_raid.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "jewels"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_pizzeria)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_pizzeria() -> Node3D:
	var pizzeria: PizzaRaid = PIZZERIA.instantiate()
	pizzeria.case_seed = SEED
	pizzeria.story_id = _story
	return pizzeria


func test_muzza_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	assert_false(guest.muzza.is_physics_processing(), "the guest's Don Muzza only follows")
	host.muzza.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.muzza.complaint - 30.0) < 0.5 \
		and guest.muzza.global_position.distance_to(host.muzza.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.muzza.complaint, host.muzza.complaint, 0.5)


func test_the_phone_from_a_guest_sends_him_to_the_dough_table_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.phone.button)
	await wait_until(func() -> bool: return host.muzza.errand() == "printer", 5.0)
	assert_eq(host.muzza.errand(), "printer", "the guest's call reached the host")


func test_the_dough_grows_on_every_pc() -> void:
	_story = "crazy_yeast"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	(host.rig as CrazyYeastRig).grow()
	(host.rig as CrazyYeastRig).grow()
	await wait_until(func() -> bool: return (guest.rig as CrazyYeastRig).size == 2, 5.0)
	assert_almost_eq(guest.dough_balls[0].scale.x, CrazyYeastRig.SIZES[2], 0.01)


func test_the_oven_put_out_on_the_host_is_out_on_the_guest() -> void:
	_story = "oven_tunnel"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	(host.rig as OvenTunnelRig).put_out_oven()
	await wait_until(func() -> bool: return not guest.oven.lit, 5.0)
	assert_false(guest.oven.lit, "a guest can crawl in too")


func test_the_phones_ring_on_every_pc() -> void:
	_story = "phone_backpack"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	(host.rig as PhoneBackpackRig).ring()
	await wait_until(func() -> bool: return (guest.rig as PhoneBackpackRig).ring_label.visible, 5.0)
	assert_eq((guest.rig as PhoneBackpackRig).rings, 1)


func test_the_giant_pizza_swung_on_the_host_swings_on_the_guest() -> void:
	_story = "giant_pizza"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PizzaRaid = OnlinePcs.level(pcs[0])
	var guest: PizzaRaid = OnlinePcs.level(pcs[1])
	host.giant_pizza.swing_open()
	await wait_until(func() -> bool: return guest.giant_pizza.is_open, 5.0)
	assert_true(guest.giant_pizza.is_open, "the safe shows on the guest too")
