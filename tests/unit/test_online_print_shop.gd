extends GutTest

## The print shop raid online (allanamiento-imprenta.md, step 9): Don Renglón is run by the host and followed by the
## guests; the lever and the fax go from any PC; the press's runs and jams, what it printed, the barrels, the panes,
## the jars, Tipito and the story's clues are decided on the host and show on every guest; a sticker on the face only
## lands on each PC's own cop.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SHOP := preload("res://scenes/levels/print_shop.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "fake_bills"


func before_each() -> void:
	_story = "fake_bills"
	_pcs = OnlinePcs.new(self, Callable(), _make_shop)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_shop() -> Node3D:
	var shop: PrintShop = SHOP.instantiate()
	shop.case_seed = SEED
	shop.story_id = _story
	return shop


func test_renglon_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_npc.is_physics_processing(), "the guest's Don Renglón only follows")
	host.owner_npc.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_npc.complaint - 30.0) < 0.5, 5.0)
	assert_almost_eq(guest.owner_npc.complaint, 30.0, 0.5)


func test_the_lever_from_a_guest_runs_the_press_and_the_host_ends_it() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.press.lever)
	await wait_until(func() -> bool: return host.press.running and guest.press.running, 5.0)
	assert_true(host.press.running, "the guest's lever reached the host")
	assert_eq(guest.press.runs, host.press.runs, "same run, same ink")
	host.press.stop()
	await wait_until(func() -> bool: return not guest.press.running, 5.0)
	assert_false(guest.press.running, "it stops on the guest when it stops on the host")
	assert_eq(guest.press.belt.constant_linear_velocity, Vector3.ZERO, "and its belt stands still")
	host.press.start()
	host.press.stamp(host.main, 2)
	await wait_until(func() -> bool: return guest.main.get_meta("press_ink", -1) == 2, 5.0)
	assert_eq(guest.main.get_meta("press_ink", -1), 2, "printed on the host, printed on the guest")
	assert_true(guest.main.has_node("PressStamp"))


func test_the_guests_press_never_starts_on_its_own_clock() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	host.press.set_physics_process(false)
	guest.press.wait_left = 0.01
	await wait_physics_frames(5)
	assert_false(guest.press.running, "only the host's clock starts it")


func test_barrels_panes_and_jars_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	host.tip_barrel(1, Vector3(1, 0, 0))
	host.break_pane(2)
	host.break_jar(3)
	await wait_until(func() -> bool: return guest.tipped == [1] and guest.cracked == [2] and guest.broken_jars == [3],
		5.0)
	assert_eq(guest.tipped, [1])
	assert_eq(guest.tipped_ways[1], Vector3(1, 0, 0), "it falls the same way")
	assert_eq(guest.cracked, [2])
	assert_eq(guest.broken_jars, [3])
	assert_eq(guest.ink.puddles.size(), host.ink.puddles.size(), "the same puddles")
	assert_eq(guest.fines, host.fines)


func test_the_fax_from_a_guest_and_tipito_are_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.fax.button)
	await wait_until(func() -> bool: return host.fax.is_busy() and guest.fax.order.visible, 5.0)
	assert_eq(guest.fax.distractions, host.fax.distractions)
	host.fax.fix()
	await wait_until(func() -> bool: return not guest.fax.order.visible, 5.0)
	assert_false(guest.fax.is_busy(), "the order goes away on the guest when he's done on the host")
	host.kid._tell("TIPITO_THANKS", 4.0)
	await wait_until(func() -> bool: return guest.kid.news_count == host.kid.news_count, 5.0)
	assert_eq((guest.kid.get_node("Bubble") as Label3D).text, "TIPITO_THANKS", "he says it on the guest")


func test_the_host_decides_the_story_clues() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as FakeBillsRig
	var guest_rig := guest.rig as FakeBillsRig
	host_rig.set_physics_process(false)
	OnlinePcs.own_cop(pcs[1]).global_position = guest.to_global(guest_rig.basket_top())
	await wait_seconds(FakeBillsRig.CHECK_EVERY * 2.5)
	assert_false(guest_rig.noticed, "the guest doesn't decide it on its own")
	host_rig.notice()
	await wait_until(func() -> bool: return guest_rig.noticed, 5.0)
	assert_true(guest_rig.noticed, "the bad bill shows on the guest when the host saw it")


func test_a_sticker_only_lands_on_each_pcs_own_cop() -> void:
	_story = "fake_stickers"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PrintShop = OnlinePcs.level(pcs[0])
	var guest: PrintShop = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	var near_tray := Vector3(PrintShop.TRAY_X.y + 1.0, PrintShop.FLOOR_TOP, 1.5)
	guest_cop.global_position = guest.to_global(near_tray)
	await wait_until(func() -> bool: return copy.global_position.distance_to(host.to_global(near_tray)) < 0.3, 5.0)
	host.press.start()
	await wait_until(func() -> bool: return (guest.rig as FakeStickersRig).on_face.has(guest_cop), 5.0)
	assert_true((guest.rig as FakeStickersRig).on_face.has(guest_cop), "on its own PC")
	assert_false((host.rig as FakeStickersRig).on_face.has(copy), "not on the host's copy")
