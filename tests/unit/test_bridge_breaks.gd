extends GutTest

## The bridge falls apart (politico-puente.md, step 3, decision 178): after a creak, a span drops its planks into the
## canal, a pillar sinks and its spans fall if nobody straightens it, a railing piece falls; the deputy's jump breaks the
## span ahead of him; and his dips: wet and on again the first time, home the second.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")

var park: BridgePark
var breaks: BridgeBreaks


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	park.get_node("Cop").input_enabled = false
	add_child_autofree(park)
	breaks = park.breaks
	await wait_physics_frames(2)


func _loose() -> Array:
	return park.get_children().filter(func(n: Node) -> bool: return n is LoosePlank and n.name.begins_with("Loose"))


func test_nothing_breaks_before_the_deputy_starts() -> void:
	breaks.next_left = 0.05
	await wait_physics_frames(10)
	assert_true(breaks.warnings.is_empty())
	assert_eq(breaks.breaks, 0)


func test_once_he_starts_something_creaks_then_breaks() -> void:
	watch_signals(breaks)
	park.ceremony.start()
	breaks.next_left = 0.05
	await wait_physics_frames(10)
	assert_signal_emit_count(breaks, "warned", 1)
	assert_eq(breaks.breaks, 0, "a creak first")
	breaks.warnings[0][2] = 0.05
	await wait_physics_frames(10)
	assert_signal_emit_count(breaks, "broke", 1)
	assert_almost_eq(breaks.next_left, BridgeBreaks.EVERY, 0.5, "and the next one in EVERY seconds")


func test_a_span_drops_both_planks_into_the_canal() -> void:
	breaks.warn("span", 6)
	breaks.warnings[0][2] = 0.05
	await wait_physics_frames(5)
	assert_false(breaks.whole(6))
	assert_null(park.plank(6, 0))
	assert_null(park.plank(6, 1))
	assert_eq(_loose().size(), 2, "two loose planks")
	await wait_seconds(1.5)
	for plank: LoosePlank in _loose():
		assert_lt(park.to_local(plank.global_position).y, BridgePark.DECK_TOP - 1.0, "down in the canal")


func test_a_sunk_pillar_sags_its_spans_until_straightened() -> void:
	breaks.warn("pillar", 1)
	breaks.warnings[0][2] = 0.05
	await wait_physics_frames(5)
	assert_true(breaks.sagging.has(1))
	assert_eq(BridgeBreaks.spans_over(1), [3, 4] as Array[int])
	var low := park.plank(3, 1).position.y
	assert_lt(low, BridgePark.DECK_TOP - BridgePark.PLANK.y / 2 - 0.1, "the planks over it sag")
	breaks.straighten(1)
	assert_false(breaks.sagging.has(1))
	assert_almost_eq(park.plank(3, 1).position.y, BridgePark.DECK_TOP - BridgePark.PLANK.y / 2, 0.001, "level again")


func test_a_sagging_pillar_left_alone_drops_its_spans() -> void:
	watch_signals(breaks)
	breaks.warn("pillar", 2)
	breaks.warnings[0][2] = 0.05
	await wait_physics_frames(5)
	breaks.sagging[2] = 0.05
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(breaks, "collapsed", [2])
	assert_false(breaks.whole(5))
	assert_false(breaks.whole(6))


func test_a_railing_piece_falls() -> void:
	var rail := park.rails[4]
	breaks.warn("rail", 4)
	breaks.warnings[0][2] = 0.05
	await wait_physics_frames(5)
	assert_null(park.rails[4])
	assert_false(is_instance_valid(rail))
	assert_not_null(park.get_node_or_null("FallenRail4"))


func test_his_jump_breaks_the_span_ahead() -> void:
	watch_signals(breaks)
	park.ceremony.jumped.emit(1, park.to_global(Vector3(BridgePark.STOPS[1], BridgePark.DECK_TOP, 0)))
	assert_signal_emitted_with_parameters(breaks, "warned", ["span", 4])


func test_his_first_dip_he_climbs_out_and_goes_on_the_second_he_goes_home() -> void:
	var dip := park.dip
	watch_signals(dip)
	park.ceremony.start()
	park.politician.global_position = park.to_global(Vector3(2, 0.1, 6))
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(dip, "dipped", [1])
	assert_true(dip.wet())
	assert_eq(park.politician.said(), "BRIDGE_LUSTRE_DIP")
	dip.out_left = 0.05
	await wait_physics_frames(5)
	var out := park.to_local(park.politician.global_position)
	assert_gt(out.y, BridgePark.DECK_TOP - 0.3, "back up on the bridge")
	assert_gt(out.x, 0.0, "at the nearer end")
	assert_eq(park.ceremony.state, BridgeCeremony.State.WALKING)
	park.politician.global_position = park.to_global(Vector3(-2, 0.1, 6))
	await wait_physics_frames(3)
	assert_signal_emitted(dip, "went_home")
	assert_eq(park.ceremony.state, BridgeCeremony.State.OVER)
