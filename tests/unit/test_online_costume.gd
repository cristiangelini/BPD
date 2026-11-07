extends GutTest

## The costume shop online (allanamiento-disfraces.md, step 8): Don Fantoche, Mimí and the customers are run by the host
## and followed by the guests, the mirror and the display case broken on the host break on the guest, the light switch
## works from any PC and the smoke the host's hat lets out puffs on the guest too.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SHOP := preload("res://scenes/levels/costume_shop.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "bear_loot"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_shop)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_shop() -> Node3D:
	var shop: CostumeShop = SHOP.instantiate()
	shop.case_seed = SEED
	shop.story_id = _story
	return shop


func test_fantoche_mimi_and_the_customers_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CostumeShop = OnlinePcs.level(pcs[0])
	var guest: CostumeShop = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_boss.is_physics_processing(), "the guest's Don Fantoche only follows")
	assert_false(guest.niece.is_physics_processing(), "and so does Mimí")
	assert_false(guest.customers[0].is_physics_processing(), "and the customers")
	host.owner_boss.complaint = 30.0
	host.niece.find(OnlinePcs.own_cop(pcs[0]))
	host.customers[0].say("CUSTOMER_ITCHY")
	await wait_until(func() -> bool: return absf(guest.owner_boss.complaint - 30.0) < 0.5 and guest.niece.is_found() \
		and guest.customers[0].said() == "CUSTOMER_ITCHY", 5.0)
	assert_almost_eq(guest.owner_boss.complaint, 30.0, 0.5)
	assert_true(guest.niece.is_found(), "found on every PC")
	assert_eq(guest.customers[0].said(), "CUSTOMER_ITCHY")
	host.niece._found_left = 0.01
	await wait_until(func() -> bool: return not guest.niece.is_found() \
		and guest.niece.global_position.distance_to(host.niece.global_position) < 0.1, 5.0)
	assert_eq(guest.niece.spot, host.niece.spot, "hidden again on the host's spot")


func test_the_mirror_and_the_display_case_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CostumeShop = OnlinePcs.level(pcs[0])
	var guest: CostumeShop = OnlinePcs.level(pcs[1])
	host.break_mirror()
	host.break_mask_case()
	await wait_until(func() -> bool: return guest.mirror_cracked and guest.case_broken, 5.0)
	assert_true(guest.mirror_cracked)
	assert_true(guest.case_broken)


func test_a_guest_turns_the_lights_off_everywhere() -> void:
	_story = "neighborhood_ghost"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CostumeShop = OnlinePcs.level(pcs[0])
	var guest: CostumeShop = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", (guest.rig as NeighborhoodGhostRig).switch)
	await wait_until(func() -> bool: return (host.rig as NeighborhoodGhostRig).dark \
		and (guest.rig as NeighborhoodGhostRig).dark, 5.0)
	assert_true((host.rig as NeighborhoodGhostRig).dark, "dark on the host")
	assert_true((guest.rig as NeighborhoodGhostRig).dark, "and on the guest")


func test_the_hosts_smoke_puffs_on_the_guest() -> void:
	_story = "smoke_bombs"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CostumeShop = OnlinePcs.level(pcs[0])
	var guest: CostumeShop = OnlinePcs.level(pcs[1])
	(host.rig as SmokeBombsRig).hat.puff()
	(host.rig as SmokeBombsRig)._pink_left = 0.01
	await wait_until(func() -> bool: return (guest.rig as SmokeBombsRig).hat.puffs == 1 \
		and (guest.rig as SmokeBombsRig).pink_clouds == 1, 5.0)
	assert_eq((guest.rig as SmokeBombsRig).hat.puffs, 1, "the hat's cloud")
	assert_eq((guest.rig as SmokeBombsRig).pink_clouds, 1, "and the stock room's")
	await wait_physics_frames(30)
	assert_eq((guest.rig as SmokeBombsRig).pink_clouds, 1, "only the host's clock makes them")
