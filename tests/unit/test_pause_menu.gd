extends GutTest

## Esc during a case (online.md, "Menú con Esc"): solo it stops the game, online the others keep playing.

const PCS := preload("res://tests/unit/online_pcs.gd")

var pcs: PCS


func before_each() -> void:
	pcs = PCS.new(self)


func after_each() -> void:
	Net.pause_menu.visible = false
	get_tree().paused = false
	pcs.free_all()
	await wait_process_frames(2)


func test_solo_it_stops_the_game_until_you_go_on() -> void:
	var menu: PauseMenu = Net.pause_menu
	menu.open()
	assert_true(menu.visible)
	assert_true(get_tree().paused, "solo, nothing moves while the menu is open")
	assert_false(menu._hint.visible)
	assert_false(menu._invite.visible, "no room, nobody to invite")
	assert_eq(menu._leave.text, "PAUSE_LEAVE")
	menu.close()
	assert_false(menu.visible)
	assert_false(get_tree().paused)


func test_online_the_case_keeps_going_and_leaving_closes_the_room() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var menu: PauseMenu = host.pause_menu
	menu.open()
	assert_false(get_tree().paused, "online the others keep playing")
	assert_true(menu._hint.visible)
	assert_eq(menu._leave.text, "PAUSE_LEAVE_ROOM")
	watch_signals(guest)
	menu.leave()
	assert_false(host.is_online())
	await wait_until(func() -> bool: return get_signal_emit_count(guest, "session_ended") > 0, 5.0)
	assert_signal_emitted_with_parameters(guest, "session_ended", ["NET_HOST_LEFT"])


func test_the_texts_are_translated() -> void:
	for key in ["PAUSE_TITLE", "PAUSE_ONLINE_HINT", "PAUSE_RESUME", "PAUSE_LEAVE", "PAUSE_LEAVE_ROOM"]:
		assert_ne(TranslationServer.translate(key), key, key)
