extends GutTest

## The prison tunnel online (carcel-tunel.md, step 7; docs/diseno/online.md): the host's plan, hideouts and case
## decide, and every PC sees the same inmates, dirt, hideouts, far end, runners and counts.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const TUNNEL_SCENE := preload("res://scenes/levels/prison_tunnel.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = TUNNEL_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.tunnel_case.follower)
	assert_true(guest.tunnel.follower)
	assert_true(guest.tunnel.hideouts[0].follower, "only the host's hideouts count")
	assert_true(guest.tunnel.inmates[0].follower, "only the host's inmates walk")
	assert_eq(guest.tunnel.tunnel_cell, host.tunnel.tunnel_cell, "the same cell from the same seed")
	assert_eq(guest.tunnel.gang, host.tunnel.gang)


func test_yard_time_and_the_dirt_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.tunnel.start()
	await wait_until(func() -> bool: return guest.tunnel.inmates[0].busy, 5.0)
	host.tunnel._on_dropped_dirt(null, host.tunnel.inmates[0].global_position)
	await wait_until(func() -> bool: return guest.tunnel.dirt.get_child_count() == 1, 5.0)
	var bit := guest.tunnel.dirt.get_child(0) as TunnelDirt
	assert_eq(bit.kind, TunnelDirt.Kind.PILE)
	await wait_until(func() -> bool: return bit.global_position.distance_to(
		host.tunnel.dirt.get_child(0).global_position) < 0.05, 5.0)


func test_the_digger_out_of_sight_and_the_metres_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.tunnel.start()
	var first := host.tunnel.inmates[host.tunnel.gang[0]]
	first.in_tunnel = true
	first._set_seen(false)
	host.tunnel.digger = first
	host.tunnel.shift_left = 999.0
	host.tunnel.dug = 12.0
	var copy := guest.tunnel.inmates[host.tunnel.gang[0]]
	await wait_until(func() -> bool: return not copy.visible, 5.0)
	assert_true(copy.in_tunnel)
	await wait_until(func() -> bool: return guest.tunnel.dug >= 12.0, 5.0)
	assert_eq(guest.tunnel_case.rows()[1].text, tr("OBJ_TUNNEL_LEFT") % [ceili(guest.tunnel.left_to_dig()), 30])


func test_a_found_tunnel_lets_out_a_runner_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.tunnel.start()
	var first := host.tunnel.inmates[host.tunnel.gang[0]]
	first.in_tunnel = true
	host.tunnel.digger = first
	var hideout := host.tunnel.tunnel_hideout()
	hideout.set_checked(true)
	hideout.checked_one.emit(hideout, true)
	assert_true(host.tunnel.is_found)
	await wait_until(func() -> bool: return guest.tunnel.runners.size() == 1, 5.0)
	assert_false(guest.tunnel.runners[0].glow_eyes, "daylight")
	await wait_physics_frames(2)
	assert_not_null(OwnerEscort.of(guest.tunnel.runners[0]), "the guest's cops can walk it to the cell")
	await wait_until(func() -> bool: return guest.tunnel.tunnel_hideout().is_open(), 5.0)
	await wait_until(func() -> bool: return guest.tunnel.is_found, 5.0)


func test_the_guest_cannot_find_it_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	var hideout := guest.tunnel.tunnel_hideout()
	hideout.checked_by = guest.get_node("Cop")
	hideout._check_left = 0.0
	await wait_physics_frames(5)
	assert_false(guest.tunnel.is_found, "the host decides")
	assert_false(hideout.is_open())


func test_the_far_end_and_the_seal_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.tunnel.exit.peek_out()
	host.tunnel._escape()
	await wait_until(func() -> bool: return guest.tunnel.exit.is_showing(), 5.0)
	await wait_until(func() -> bool: return guest.tunnel.escaped == 1, 5.0)
	var hideout := host.tunnel.tunnel_hideout()
	hideout.seal()
	host.tunnel.is_sealed = true
	host.tunnel.sealed.emit()
	await wait_until(func() -> bool: return guest.tunnel.tunnel_hideout().sealed, 5.0)
	await wait_until(func() -> bool: return guest.tunnel_case.solved_it, 5.0)
	assert_false(guest.tunnel_case.sealed_early, "the far end already showed")
