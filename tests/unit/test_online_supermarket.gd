extends GutTest

## The supermarket raid online (allanamiento-super.md, step 8): Don Ofertón, Lalo and the customers are run by the host
## and followed by the guests, a guest's price button sends the host's Don Ofertón to the checkout, a guest pushing a
## cart is as fast on the host (the customers complain), and the pyramid, the fridge, the loudspeaker and aisle 13's
## gondola the host decides show on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/supermarket.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "super_dates"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_store)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_store() -> Node3D:
	var store: Supermarket = SCENE.instantiate()
	store.case_seed = SEED
	store.story_id = _story
	return store


func test_don_oferton_lalo_and_the_customers_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Supermarket = OnlinePcs.level(pcs[0])
	var guest: Supermarket = OnlinePcs.level(pcs[1])
	assert_false(guest.manager.is_physics_processing(), "the guest's Don Ofertón only follows")
	assert_false(guest.stocker.is_physics_processing(), "and Lalo")
	assert_true(guest.customers[0].follower, "and the customers")
	host.manager.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.manager.complaint - 30.0) < 0.5 \
		and guest.customers[0].global_position.distance_to(host.customers[0].global_position) < 0.2, 5.0)
	assert_almost_eq(guest.manager.complaint, 30.0, 0.5)
	assert_lt(guest.customers[0].global_position.distance_to(host.customers[0].global_position), 0.2)


func test_a_price_button_from_a_guest_sends_the_host_s_don_oferton() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Supermarket = OnlinePcs.level(pcs[0])
	var guest: Supermarket = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.price_call.buttons[1])
	await wait_until(func() -> bool: return host.price_call.calls > 0 and guest.price_call.calls > 0, 5.0)
	assert_eq(host.price_call.calls, 1, "the guest's button reached the host")
	assert_eq(host.manager.errand(), "printer", "and Don Ofertón goes to look up the price")


func test_a_guest_s_cart_is_as_fast_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Supermarket = OnlinePcs.level(pcs[0])
	var guest: Supermarket = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.global_position = guest.carts[3].global_position + Vector3(0, 0.1, 1.3)
	cop.act("use", guest.carts[3])
	await wait_until(func() -> bool: return host.carts[3].pusher != null, 5.0)
	assert_not_null(host.carts[3].pusher, "pushed on the host too")
	var top := 0.0
	for i in 40:
		cop.global_position += Vector3(0, 0, -0.05)
		await wait_physics_frames(1)
		top = maxf(top, host.carts[3].top_speed)
	assert_gt(top, 1.0, "the host's copy moves as fast")


func test_the_pyramid_the_fridge_and_the_loudspeaker_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Supermarket = OnlinePcs.level(pcs[0])
	var guest: Supermarket = OnlinePcs.level(pcs[1])
	host.topple_pyramid()
	host.break_fridge()
	host.announce(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return guest.pyramid_fallen and guest.fridge_cracked \
		and guest._shown_lines == host.announced, 5.0)
	assert_true(guest.pyramid_fallen)
	assert_true(guest.fridge_cracked)
	assert_eq(guest._shown_lines, 1, "the loudspeaker's line, once")
	assert_eq(guest.announced, 0, "said by the host's Don Ofertón")


func test_aisle_13_opened_on_the_host_opens_on_the_guest() -> void:
	_story = "super_aisle13"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Supermarket = OnlinePcs.level(pcs[0])
	var guest: Supermarket = OnlinePcs.level(pcs[1])
	guest.rig.pushed = 10.0
	await wait_physics_frames(5)
	assert_false(guest.rig.opened, "a guest doesn't decide it")
	host.rig.open()
	await wait_until(func() -> bool: return guest.rig.opened, 5.0)
	assert_true(guest.rig.opened)
