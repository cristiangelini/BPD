extends GutTest

## Players' names (docs/diseno/online.md, "La sala"): the Steam name in the room and over each other player's cop,
## "Policía N" without Steam.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func test_without_steam_players_are_cop_n() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	# With Steam open on this PC both PCs told their real Steam name: forget it, as if Steam were closed.
	for net: Node in pcs:
		net.names.clear()
	var guest_id: int = pcs[1].multiplayer.get_unique_id()
	assert_eq(pcs[0].player_name(guest_id), tr("COP_NAME") % 2)
	assert_eq(pcs[1].player_name(Net.HOST_ID), tr("COP_NAME") % 1)


func test_a_guest_name_reaches_everyone_cut_to_size() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Node = pcs[0]
	var guest: Node = pcs[1]
	var guest_id: int = guest.multiplayer.get_unique_id()
	guest._tell_name.rpc_id(Net.HOST_ID, "  Comisaria Rodriguez de la Esquina Norte  ")
	await wait_until(func() -> bool: return guest.names.get(guest_id, "") != "", 3.0)
	assert_eq(host.player_name(guest_id), "Comisaria Rodriguez de l", "trimmed and cut to %d" % Net.NAME_LENGTH)
	assert_eq(guest.player_name(guest_id), host.player_name(guest_id), "the guest sees the same list")


func test_other_cops_carry_their_name_over_the_head() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Node = pcs[0]
	var guest_id: int = pcs[1].multiplayer.get_unique_id()
	var copy: Node3D = host.cop_syncs[guest_id].cop
	var tag := copy.get_node_or_null("NameTag") as Label3D
	assert_not_null(tag)
	assert_eq(tag.text, host.player_name(guest_id))
	assert_eq(tag.modulate, Lobby.SKIN_COLORS[1], "in the guest's skin color")
	assert_null(host.cop_syncs[Net.HOST_ID].cop.get_node_or_null("NameTag"), "not over your own head")


func test_a_leaving_player_takes_the_name_away() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Node = pcs[0]
	var guest: Node = pcs[1]
	var guest_id: int = guest.multiplayer.get_unique_id()
	guest._tell_name.rpc_id(Net.HOST_ID, "Ana")
	await wait_until(func() -> bool: return host.names.get(guest_id, "") == "Ana", 3.0)
	guest.leave()
	await wait_until(func() -> bool: return not host.players.has(guest_id), 3.0)
	assert_false(host.names.has(guest_id))
