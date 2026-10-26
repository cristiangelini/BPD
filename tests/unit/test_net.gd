extends GutTest

## The online session (docs/diseno/online.md): a host and guests over ENet on this PC, each with its own multiplayer
## branch in the tree, as if they were different PCs.

const NET_SCRIPT := preload("res://scripts/core/net.gd")

var _port := 0
var _nets: Array[Node] = []


func before_each() -> void:
	_port = randi_range(20000, 40000)
	_nets.clear()


func after_each() -> void:
	for net in _nets:
		net.leave()
		net.get_parent().queue_free()
	await wait_process_frames(2)


## A Net node in its own branch with its own multiplayer, like the autoload on another PC.
func _new_net() -> Node:
	var branch := Node.new()
	branch.name = "Pc%d" % _nets.size()
	add_child(branch)
	get_tree().set_multiplayer(SceneMultiplayer.new(), branch.get_path())
	var net: Node = NET_SCRIPT.new()
	net.name = "Net"
	net.change_scenes = false
	branch.add_child(net)
	_nets.append(net)
	return net


func _host() -> Node:
	var host := _new_net()
	assert_eq(host.host(_port), OK, "the room should open")
	return host


func _guest(host: Node) -> Node:
	var guest := _new_net()
	var before: int = host.players.size()
	assert_eq(guest.join("127.0.0.1", _port), OK)
	await wait_until(func() -> bool: return guest.players.size() == before + 1, 5.0)
	return guest


func test_free_slot_takes_the_lowest_free_one() -> void:
	assert_eq(NET_SCRIPT.free_slot([]), 0)
	assert_eq(NET_SCRIPT.free_slot([0, 1]), 2)
	assert_eq(NET_SCRIPT.free_slot([0, 2, 3]), 1, "the slot of a player who left is free again")
	assert_eq(NET_SCRIPT.free_slot([0, 1, 2, 3]), -1, "four cops at most")


func test_solo_is_offline_and_counts_as_host() -> void:
	var net := _new_net()
	assert_false(net.is_online())
	assert_true(net.is_host(), "solo, the player's game is the one that counts")
	assert_eq(net.my_slot(), 0)


func test_host_takes_slot_zero() -> void:
	var host := _host()
	assert_true(host.is_online())
	assert_true(host.is_host())
	assert_eq(host.players, {1: 0})


func test_guest_joins_with_the_next_slot_and_both_see_the_list() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	assert_true(guest.is_online())
	assert_false(guest.is_host())
	assert_eq(guest.my_slot(), 1, "the second cop gets the second color")
	assert_eq(guest.players, host.players, "the guest sees the host's list")


func test_a_leaving_guest_frees_the_slot() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	guest.leave()
	await wait_until(func() -> bool: return host.players.size() == 1, 5.0)
	assert_eq(host.players, {1: 0})


func test_fifth_player_is_refused() -> void:
	var host := _host()
	for i in 3:
		await _guest(host)
	assert_eq(host.players.size(), 4)
	var fifth := _new_net()
	watch_signals(fifth)
	fifth.join("127.0.0.1", _port)
	await wait_until(func() -> bool: return get_signal_emit_count(fifth, "session_ended") > 0, 5.0)
	assert_signal_emitted_with_parameters(fifth, "session_ended", ["NET_ROOM_FULL"])
	assert_false(fifth.is_online())
	assert_eq(host.players.size(), 4, "the room keeps its four cops")


func test_start_opens_the_same_case_for_everyone() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	watch_signals(host)
	watch_signals(guest)
	host.start_match()
	await wait_until(func() -> bool: return get_signal_emit_count(guest, "match_started") > 0, 5.0)
	var on_host: Array = get_signal_parameters(host, "match_started")
	var on_guest: Array = get_signal_parameters(guest, "match_started")
	assert_eq(on_guest, on_host, "same place and same seed on every PC")
	assert_true(PlaceDraw.PLACES.has(on_host[0]))
	assert_ne(on_host[1], 0)
	assert_true(guest.in_match)


func test_the_hosts_owner_in_custody_comes_with_the_case() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	PlaceDraw.custody = {"owner": "grandpa", "story": "bingo", "slips": [], "missed": 300}
	var custody := PlaceDraw.custody.duplicate()
	host.start_match()
	await wait_until(func() -> bool: return guest.in_match, 5.0)
	PlaceDraw.custody = {}
	assert_eq(guest.match_place, "interrogation", "an owner in custody is interrogated next")
	assert_eq(guest.match_custody, custody, "the guest gets the host's owner for the chair")
	var late := _new_net()
	late.join("127.0.0.1", _port)
	await wait_until(func() -> bool: return late.in_match, 5.0)
	assert_eq(late.match_custody, custody, "also a player who comes in during the case")


func test_online_the_chase_and_the_crime_scene_come_up_too() -> void:
	var host := _host()
	# Without an owner in custody or a campaign left by another test, which would make it an interrogation.
	Campaign.current = null
	PlaceDraw.custody = {}
	var places := {}
	for i in 100:
		places[host.draw_place(i + 1)] = true
	assert_true(places.has("chase"), "the chase is synced (persecucion.md, \"Online\")")
	assert_true(places.has("crime_scene"), "and the crime scene")
	assert_true(places.has("circus"), "and the circus")
	for i in 100:
		assert_eq(host.draw_place(i + 1), PlaceDraw.pick(i + 1, [], PlaceDraw.shift_now()), "the same draw as alone")


func test_only_the_host_starts_the_case() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	watch_signals(host)
	guest.start_match()
	await wait_process_frames(10)
	assert_signal_not_emitted(host, "match_started")


func test_a_late_player_goes_straight_into_the_case() -> void:
	var host := _host()
	await _guest(host)
	watch_signals(host)
	host.start_match()
	await wait_process_frames(5)
	var late := _new_net()
	watch_signals(late)
	late.join("127.0.0.1", _port)
	await wait_until(func() -> bool: return get_signal_emit_count(late, "match_started") > 0, 5.0)
	assert_eq(get_signal_parameters(late, "match_started"), get_signal_parameters(host, "match_started"),
		"the same place and seed as the others")
	assert_eq(late.players.size(), 3)
	assert_true(late.in_match)


func test_a_guest_in_a_case_goes_back_to_the_room_with_the_notice_when_the_host_leaves() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	host.start_match()
	await wait_until(func() -> bool: return guest.in_match, 5.0)
	watch_signals(guest)
	host.leave()
	await wait_until(func() -> bool: return get_signal_emit_count(guest, "session_ended") > 0, 5.0)
	assert_eq(Lobby.notice, "NET_HOST_LEFT", "the room screen will say the host closed the room")
	assert_false(guest.in_match)
	Lobby.notice = ""


func test_the_room_screen_shows_the_notice_once() -> void:
	Lobby.notice = "NET_HOST_LEFT"
	var lobby: Control = add_child_autofree(load("res://scenes/ui/lobby.tscn").instantiate())
	assert_eq(lobby.get_node("%Status").text, "NET_HOST_LEFT")
	assert_eq(Lobby.notice, "", "only once")


func test_guests_go_back_when_the_host_closes_the_room() -> void:
	var host := _host()
	var guest: Node = await _guest(host)
	watch_signals(guest)
	host.leave()
	await wait_until(func() -> bool: return get_signal_emit_count(guest, "session_ended") > 0, 5.0)
	assert_signal_emitted_with_parameters(guest, "session_ended", ["NET_HOST_LEFT"])
	assert_false(guest.is_online())
	assert_true(guest.players.is_empty())



func test_npc_moves_go_in_packets_under_the_mtu() -> void:
	var ids := PackedInt32Array()
	var states := []
	for i in 40:
		ids.append(i)
		states.append([Transform3D.IDENTITY, "TRANSFER_BATHROOM_THANKS", true, 0.0, false, [i, 90.0, true], null])
	var parts := NpcSync._by_size(ids, states)
	var count := 0
	for part: Array in parts:
		assert_lt(var_to_bytes(part).size(), 1392, "under ENet's MTU")
		count += (part[0] as PackedInt32Array).size()
	assert_eq(count, 40, "every one goes")
