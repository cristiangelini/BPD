extends GutTest

## The interrogation online (docs/diseno/online.md, "Qué se sincroniza"): the host's case counts every cop's action,
## and every PC sees the same meters, lines, confessions on the table and end of shift.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/interrogation.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: InterrogationLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> InterrogationLevel:
	return OnlinePcs.level(net) as InterrogationLevel


func _case(net: Node) -> InterrogationCase:
	return _level(net).case


func _prop(net: Node, action: String) -> InterrogationProp:
	return _level(net).get_node("City").find_child("Prop_" + action, true, false) as InterrogationProp


## Host and guest with the case given.
func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_case(pcs[0]).give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	return pcs


func test_only_the_host_counts_and_the_guest_sees_the_meters_and_the_line() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_false(host.follower)
	assert_true(guest.follower)
	assert_false(guest.act("calm"), "a guest's case doesn't count on its own")
	OnlinePcs.own_cop(pcs[1]).act("use", _prop(pcs[1], "slam_table"))
	await wait_until(func() -> bool: return guest.nerves > 0.0, 5.0)
	assert_eq(host.nerves, InterrogationCase.ACTIONS.slam_table.nerves, "the guest's slam counted once, on the host")
	assert_eq(guest.nerves, host.nerves, "the guest's meter shows it")
	assert_eq(_level(pcs[1]).nerves_bar.value, host.nerves)
	assert_eq(guest.lawyer, host.lawyer)
	await wait_until(func() -> bool: return _level(pcs[1]).suspect.saying() != "", 5.0)
	assert_eq(_level(pcs[1]).suspect.saying(), "SUSPECT_REACT_SLAM", "his line shows on the guest")


func test_a_guest_shout_counts_on_the_host() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	# The guest moves its own cop next to him; the host's copy follows.
	guest_cop.global_position = _level(pcs[1]).suspect.global_position + Vector3(0, 0, 1.5)
	var suspect_at := _level(pcs[0]).suspect.global_position
	await wait_until(func() -> bool: return copy.global_position.distance_to(suspect_at) < 2.0, 5.0)
	_case(pcs[1]).shouted_by(guest_cop)
	await wait_until(func() -> bool: return host.nerves > 0.0, 5.0)
	assert_eq(host.nerves, InterrogationCase.ACTIONS.shout.nerves, "the host's case heard the guest's shout")


func test_the_confession_and_the_shift_end_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.nerves = 95.0
	host.act("slam_table")
	assert_true(host.confessed)
	await wait_until(func() -> bool: return guest.confessed, 5.0)
	assert_true(guest.solved_label.visible, "the guest sees it solved")
	await wait_until(func() -> bool: return guest.shift_over, InterrogationCase.SHIFT_DELAY + 5.0)
	assert_true(guest.shift_screen.visible, "the end of shift screen on the guest")
	assert_false(guest.shift_screen.get_node("%AgainButton").visible, "only the host plays the next case")
	assert_true(host.shift_screen.get_node("%AgainButton").visible)


func test_the_fans_confessions_show_on_the_guest_and_its_pick_reaches_the_host() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.suspect_id = "fan"
	host.act("calm")
	await wait_until(func() -> bool: return guest.confessions.size() == 3, 5.0)
	assert_eq(guest.confessions.map(func(sheet: FanConfession) -> String: return sheet.crime),
		host.confessions.map(func(sheet: FanConfession) -> String: return sheet.crime), "the same three, in order")
	var wrong: FanConfession = guest.confessions.filter(
		func(sheet: FanConfession) -> bool: return sheet.crime != host.crime)[0]
	OnlinePcs.own_cop(pcs[1]).act("use", wrong)
	await wait_until(func() -> bool: return guest.confessions.size() == 2, 5.0)
	assert_eq(host.confessions.size(), 2, "the guest's pick took it off the host's table")
	# "Calm" couldn't take the lawyer below 0, so only the wrong pick is on it.
	assert_eq(guest.lawyer, InterrogationCase.FAN_WRONG_LAWYER, "a wrong one brings the lawyer closer")
	var right: FanConfession = guest.confessions.filter(
		func(sheet: FanConfession) -> bool: return sheet.crime == host.crime)[0]
	OnlinePcs.own_cop(pcs[1]).act("use", right)
	await wait_until(func() -> bool: return guest.confessed, 5.0)
	assert_true(host.confessed, "the true one solves it")


func test_the_lawyer_comes_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	host.lawyer = 95.0
	host.act("slam_table")
	assert_true(host.lawyer_came)
	await wait_until(func() -> bool: return _case(pcs[1]).lawyer_came, 5.0)
	assert_not_null(_level(pcs[1]).suspect.get_parent().get_node_or_null("Lawyer"), "the guest sees him come in")
	assert_true(_case(pcs[1]).failed_label.visible)


func test_the_lights_flicker_on_the_guest_too() -> void:
	var pcs := await _on()
	var lamp := _level(pcs[1]).get_tree().get_nodes_in_group("interrogation_lamp").filter(
		func(node: Node) -> bool: return _level(pcs[1]).is_ancestor_of(node))[0] as Light3D
	_case(pcs[0]).act("flick_lights")
	await wait_until(func() -> bool: return not lamp.visible, 5.0)
	assert_false(lamp.visible, "the guest's lamp blinks")
	await wait_until(func() -> bool: return lamp.visible, 5.0)
	assert_true(lamp.visible, "and comes back on")


func test_the_coffee_machine_pours_into_the_guests_hands() -> void:
	var pcs := await _on()
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("use", _prop(pcs[1], "pour_coffee"))
	await wait_until(func() -> bool: return guest_cop.get_node("Grabber").held is CoffeeCup, 5.0)
	assert_true(guest_cop.get_node("Grabber").held is CoffeeCup, "the guest holds the cup")
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_true(copy.get_node("Grabber").held is CoffeeCup, "and the host holds it for the guest's cop")


func test_a_guest_sits_by_him_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	host.lawyer = 20.0
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var chair: InterrogationChair = _level(pcs[1]).chairs[0]
	guest_cop.act("use", chair)
	await wait_until(func() -> bool: return host.lawyer < 20.0, 5.0)
	assert_eq(host.lawyer, 20.0 + InterrogationCase.ACTIONS.sit_down.lawyer, "the host counted the good cop sitting")
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_eq(copy.seated_in, _level(pcs[0]).chairs[0], "the host sees the guest's cop on the chair")
	# The host sits him first and then tells the guest: one more trip.
	await wait_until(func() -> bool: return guest_cop.seated_in == chair, 5.0)
	assert_eq(guest_cop.seated_in, chair)
	assert_almost_eq(guest_cop.global_position.x, chair.global_position.x, 0.05, "and the guest is on it")
	guest_cop.act("use", chair)
	await wait_until(func() -> bool: return guest_cop.seated_in == null and not _level(pcs[0]).chairs[0].freeze, 5.0)
	assert_true(chair.freeze, "the guest's copy of the chair still follows the host")
	assert_false(_level(pcs[0]).chairs[0].freeze, "the host's is loose again")
