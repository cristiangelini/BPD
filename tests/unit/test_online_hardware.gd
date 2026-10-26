extends GutTest

## The hardware store online (docs/diseno/ferreteria.md, step 7): Tobías and Don Cosme are run by the host and
## followed by the guests, the screw wall slides for two cops on two PCs, and what a story reveals (the golden drawer)
## stays the host's to move.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const STORE := preload("res://scenes/levels/hardware_store.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "screw_tunnel"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_store)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_store() -> Node3D:
	var store: HardwareStore = STORE.instantiate()
	store.case_seed = SEED
	store.story_id = _story
	return store


func test_tobias_moves_searches_and_gets_annoyed_the_same_for_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host: HardwareMan = OnlinePcs.level(pcs[0]).tobias
	var on_guest: HardwareMan = OnlinePcs.level(pcs[1]).tobias
	assert_false(on_guest.is_physics_processing(), "the guest's Tobías only follows")
	on_host.global_position += Vector3(0.4, 0, -0.2)
	on_host.complaint = 30.0
	assert_true(on_host.look_for_screw())
	var synced := func() -> bool:
		return on_guest.global_position.distance_to(on_host.global_position) < 0.05 \
			and absf(on_guest.complaint - on_host.complaint) < 0.01 and on_guest.is_searching()
	await wait_until(synced, 5.0)
	assert_true(on_guest.is_searching(), "he looks for the screw on the guest's screen too")
	assert_almost_eq(on_guest.complaint, on_host.complaint, 0.01)


func test_don_cosme_asks_and_gets_his_key_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host: KeyCustomer = OnlinePcs.level(pcs[0]).cosme
	var on_guest: KeyCustomer = OnlinePcs.level(pcs[1]).cosme
	OnlinePcs.own_cop(pcs[1]).act("use", on_guest)
	await wait_until(func() -> bool: return on_host.was_asked and on_guest.was_asked, 5.0)
	assert_true(on_host.was_asked, "the guest's E reached the host's Cosme")
	on_host.take(KeyMachine.KEY_SCENE.instantiate())
	await wait_until(func() -> bool: return on_guest.served, 5.0)
	assert_true(on_guest.served)


func test_a_cop_on_each_pc_slides_the_screw_wall() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_store: HardwareStore = OnlinePcs.level(pcs[0])
	var guest_store: HardwareStore = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[0]).act("use", host_store.screw_shelf)
	await wait_physics_frames(2)
	assert_false(host_store.screw_shelf.is_open, "one cop alone can't")
	OnlinePcs.own_cop(pcs[1]).act("use", guest_store.screw_shelf)
	await wait_until(func() -> bool: return host_store.screw_shelf.is_open and guest_store.screw_shelf.is_open, 5.0)
	assert_true(host_store.screw_shelf.is_open)
	assert_true(guest_store.screw_shelf.is_open)
	var guest_drill := (guest_store.rig as TunnelRig).drill
	assert_true(guest_drill.visible)
	assert_true(guest_drill.freeze, "the guest's drill follows the host's")
	assert_false((host_store.rig as TunnelRig).drill.freeze)


func test_the_golden_drawer_opens_for_everyone() -> void:
	_story = "gold_screws"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_rig := (OnlinePcs.level(pcs[0]) as HardwareStore).rig as GoldScrewsRig
	var guest_rig := (OnlinePcs.level(pcs[1]) as HardwareStore).rig as GoldScrewsRig
	OnlinePcs.own_cop(pcs[1]).act("use", guest_rig.drawers[guest_rig.gold_index])
	await wait_until(func() -> bool: return host_rig.gold.visible and guest_rig.gold.visible, 5.0)
	assert_false(host_rig.gold.freeze, "the host's falls out of the wall")
	assert_true(guest_rig.gold.freeze, "the guest's follows it")
