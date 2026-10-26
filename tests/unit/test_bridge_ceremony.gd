extends GutTest

## Deputy Lustre opens the bridge (politico-puente.md, step 2, decision 178): he waits for his guard at the foot of the
## west ramp, walks up onto the deck, stops for 4 photos jumping once at each, and cuts the ribbon at the east end.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")

var park: BridgePark
var ceremony: BridgeCeremony


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	park.get_node("Cop").input_enabled = false
	add_child_autofree(park)
	ceremony = park.ceremony
	await wait_physics_frames(2)


## Puts him on the deck at `local` (the park's space) walking to stop `index` (STOPS.size() is the ribbon).
func _walking_to(index: int, local: Vector3) -> void:
	park.politician.global_position = park.to_global(local)
	ceremony.stop = index
	if index < BridgePark.STOPS.size():
		ceremony._walk_to(ceremony._stop_point(index))
	else:
		ceremony._walk_to(park.to_global(Vector3(BridgePark.RIBBON_X - 0.6, BridgePark.DECK_TOP, 0)))


func test_he_waits_for_a_cop_to_come_close() -> void:
	watch_signals(ceremony)
	await wait_seconds(0.3)
	assert_eq(ceremony.state, BridgeCeremony.State.WAITING, "the cops are far, at the station")
	var cop: Cop = park.get_node("Cop")
	cop.global_position = park.politician.global_position + Vector3(5, 0.1, 5)
	await wait_physics_frames(3)
	assert_signal_emitted(ceremony, "started")
	assert_eq(ceremony.state, BridgeCeremony.State.WALKING)


func test_he_walks_up_the_ramp_to_the_first_stop() -> void:
	watch_signals(ceremony)
	# Halfway up already, so the test is shorter.
	park.politician.global_position = park.to_global(Vector3(-14.0, 1.3, 0))
	ceremony.start()
	var waited := 0.0
	while ceremony.state != BridgeCeremony.State.POSING and waited < 10.0:
		await wait_seconds(0.25)
		waited += 0.25
	assert_signal_emitted_with_parameters(ceremony, "arrived", [0])
	assert_true(park.on_deck(park.politician.global_position), "up on the deck")
	assert_almost_eq(park.to_local(park.politician.global_position).x, BridgePark.STOPS[0], 0.4)


func test_he_jumps_once_at_each_stop_and_goes_on() -> void:
	watch_signals(ceremony)
	_walking_to(1, Vector3(BridgePark.STOPS[1] - 0.2, BridgePark.DECK_TOP + 0.05, 0))
	await wait_physics_frames(20)
	assert_eq(ceremony.state, BridgeCeremony.State.POSING)
	var floor_y := park.politician.global_position.y
	ceremony.stop_left = BridgeCeremony.PHOTO_TIME - BridgeCeremony.JUMP_AT + 0.05
	await wait_physics_frames(12)
	assert_signal_emit_count(ceremony, "jumped", 1)
	assert_gt(park.politician.global_position.y, floor_y + 0.1, "up in the air for the photo")
	assert_eq(park.politician.said(), "BRIDGE_LUSTRE_JUMP")
	await wait_physics_frames(60)
	assert_signal_emit_count(ceremony, "jumped", 1, "only once per stop")
	assert_true(park.on_deck(park.politician.global_position), "and lands on the deck")
	ceremony.stop_left = 0.01
	await wait_physics_frames(2)
	assert_eq(ceremony.stop, 2)
	assert_eq(ceremony.state, BridgeCeremony.State.WALKING, "on to the next stop")


func test_after_the_last_stop_he_cuts_the_ribbon() -> void:
	watch_signals(ceremony)
	_walking_to(BridgePark.STOPS.size(), Vector3(BridgePark.RIBBON_X - 0.8, BridgePark.DECK_TOP + 0.05, 0))
	await wait_physics_frames(20)
	assert_eq(ceremony.state, BridgeCeremony.State.RIBBON)
	assert_eq(park.politician.said(), "BRIDGE_LUSTRE_RIBBON")
	ceremony.stop_left = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted(ceremony, "finished")
	assert_eq(ceremony.state, BridgeCeremony.State.OVER)
	assert_eq(ceremony.done(), BridgePark.STOPS.size() + 1, "the bar is full")


func test_held_he_stays_and_the_clock_waits() -> void:
	_walking_to(0, Vector3(BridgePark.STOPS[0] - 0.2, BridgePark.DECK_TOP + 0.05, 0))
	await wait_physics_frames(20)
	var left := ceremony.stop_left
	ceremony.hold(5.0)
	await wait_physics_frames(30)
	assert_eq(ceremony.stop_left, left)
	ceremony.release()
	await wait_physics_frames(5)
	assert_lt(ceremony.stop_left, left)
