extends GutTest

## The car wash raid online (allanamiento-lavadero.md, step 8): Don Chorro is run by the host and followed by the
## guests; the tunnel and the premium wash go from any PC; the windshields, the wax, the chamois and Pompita are decided
## on the host and show on every guest.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CAR_WASH := preload("res://scenes/levels/car_wash.tscn")
const SEED := 5

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_car_wash)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_car_wash() -> Node3D:
	var car_wash: CarWash = CAR_WASH.instantiate()
	car_wash.case_seed = SEED
	car_wash.story_id = "laundered_money"
	return car_wash


func test_don_chorro_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CarWash = OnlinePcs.level(pcs[0])
	var guest: CarWash = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_npc.is_physics_processing(), "the guest's Don Chorro only follows")
	host.owner_npc.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_npc.complaint - 30.0) < 0.5 \
		and guest.owner_npc.global_position.distance_to(host.owner_npc.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.owner_npc.complaint, host.owner_npc.complaint, 0.5)


func test_the_tunnel_and_the_premium_wash_from_a_guest_work_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CarWash = OnlinePcs.level(pcs[0])
	var guest: CarWash = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.tunnel_button)
	await wait_until(func() -> bool: return host.tunnel.is_running() and guest.tunnel.is_running(), 5.0)
	assert_true(host.tunnel.is_running(), "the guest's button reached the host")
	host.tunnel.stop()
	await wait_until(func() -> bool: return not guest.tunnel.is_running(), 5.0)
	assert_false(guest.tunnel.is_running(), "it stops on the guest when it stops on the host")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.premium.button)
	await wait_until(func() -> bool: return host.premium.is_drying() and guest.premium.is_drying(), 5.0)
	assert_eq(guest.premium.distractions, host.premium.distractions)
	await wait_until(func() -> bool: return host.premium.is_out() and guest.premium.is_out(), 15.0)
	assert_true(guest.premium.is_out(), "the car rode to the drying area on the guest too")
	host.premium.fix()
	await wait_until(func() -> bool: return guest.premium.is_home() and not guest.premium.is_drying(), 15.0)
	assert_true(guest.premium.is_home(), "it backs up on the guest when he's done on the host")


func test_windshields_and_wax_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CarWash = OnlinePcs.level(pcs[0])
	var guest: CarWash = OnlinePcs.level(pcs[1])
	host.break_windshield(1)
	host.break_wax()
	await wait_until(func() -> bool: return guest.cracked == [1] and guest.wax_broken_down, 5.0)
	assert_eq(guest.cracked, [1])
	assert_true(guest.wax_broken_down)
	assert_eq(guest.fines, host.fines)


func test_a_chamois_wet_on_the_host_is_wet_on_the_guest_and_pompita_talks_on_both() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CarWash = OnlinePcs.level(pcs[0])
	var guest: CarWash = OnlinePcs.level(pcs[1])
	var cloth := host.take_chamois()
	await wait_until(func() -> bool: return guest.get_node_or_null(NodePath(cloth.name)) != null, 5.0)
	var copy := guest.get_node_or_null(NodePath(cloth.name)) as Chamois
	assert_not_null(copy, "the guest got a copy with the same name")
	assert_true(copy.dry)
	cloth.soak()
	await wait_until(func() -> bool: return not copy.dry, 5.0)
	assert_false(copy.dry, "wet on the guest too")
	host.pompita._tell("POMPITA_THANKS", 4.0)
	await wait_until(func() -> bool: return guest.pompita.news_count == host.pompita.news_count, 5.0)
	assert_eq((guest.pompita.get_node("Bubble") as Label3D).text, "POMPITA_THANKS", "he says it on the guest")
