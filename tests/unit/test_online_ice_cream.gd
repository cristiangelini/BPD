extends GutTest

## The ice cream shop online (allanamiento-heladeria.md, step 8): doña Nieve, Lucho and the stories' visitors are run
## by the host and followed by the guests, the freezers open from any PC, and what melts, cracks or falls, the cold
## room's door and the truck's jingle follow the host's.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SHOP := preload("res://scenes/levels/ice_cream_shop.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "stolen_flavors"


func before_each() -> void:
	_story = "stolen_flavors"
	_pcs = OnlinePcs.new(self, Callable(), _make_shop)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_shop() -> Node3D:
	var shop: IceCreamShop = SHOP.instantiate()
	shop.case_seed = SEED
	shop.story_id = _story
	return shop


func test_nieve_and_lucho_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	assert_false(guest.nieve.is_physics_processing(), "the guest's doña Nieve only follows")
	assert_false(guest.lucho.is_physics_processing(), "and so does Lucho")
	host.nieve.complaint = 30.0
	host.lucho.visit_now()
	await wait_until(func() -> bool: return absf(guest.nieve.complaint - 30.0) < 0.5 and guest.lucho.visible, 5.0)
	assert_almost_eq(guest.nieve.complaint, 30.0, 0.5)
	assert_true(guest.lucho.visible, "he rides up on the guest too")
	assert_eq(guest.lucho.state, host.lucho.state)


func test_a_guest_opens_a_freezer_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.freezers[0])
	await wait_until(func() -> bool: return host.freezers[0].is_open and guest.freezers[0].is_open, 5.0)
	assert_true(host.freezers[0].is_open, "the guest's E reached the host")
	assert_true(guest.freezers[0].is_open)


func test_what_melts_and_breaks_on_the_host_does_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	host.freezers[1].melt()
	host.melt_cold_room()
	host.crack_case()
	host.knock_penguin()
	await wait_until(func() -> bool: return guest.freezers[1].is_melted and guest.cold_melted and guest.case_broken \
		and guest.penguin_down, 5.0)
	assert_true(guest.freezers[1].is_melted)
	assert_true(guest.cold_melted)
	assert_eq(guest.puddles.size(), host.puddles.size(), "the same puddles to slip on")
	assert_true(guest.penguin_down)
	await wait_until(func() -> bool: return guest.raid.objective_facts().fines == host.raid.fines, 5.0)
	assert_eq(guest.raid.objective_facts().fines,
		IceCreamShop.FREEZER_FINE + IceCreamShop.COLD_FINE + IceCreamShop.CASE_FINE, "fined once, by the host")


func test_the_cold_rooms_door_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	host.cold_door.open_from_inside()
	await wait_until(func() -> bool: return guest.cold_door.is_open, 5.0)
	assert_true(guest.cold_door.is_open)
	host.cold_door.close()
	host.cold_door.locked = true
	await wait_until(func() -> bool: return not guest.cold_door.is_open and guest.cold_door.locked, 5.0)
	assert_true(guest.cold_door.locked)


func test_the_customer_who_asks_for_the_cold_comes_in_on_the_guest() -> void:
	_story = "frozen_smuggling"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	(host.rig as FrozenSmugglingRig).ask()
	var customer := (guest.rig as FrozenSmugglingRig).customer
	await wait_until(func() -> bool: return customer.visible, 5.0)
	assert_eq(customer.said(), tr("ICE_COLD_ARRIVED"))


func test_the_trucks_jingle_plays_on_the_guest() -> void:
	_story = "stolen_truck"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: IceCreamShop = OnlinePcs.level(pcs[0])
	var guest: IceCreamShop = OnlinePcs.level(pcs[1])
	(host.rig as StolenTruckRig).play_jingle()
	await wait_until(func() -> bool: return (guest.rig as StolenTruckRig).jingles == 1, 5.0)
	assert_eq((guest.rig as StolenTruckRig).jingle_text(), tr("ICE_TRUCK_JINGLE"))
