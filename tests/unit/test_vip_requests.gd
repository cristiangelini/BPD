extends GutTest

## The VIP inmate's requests, step 3 (carcel-vip.md): the bell, the seed's 6 of 10, the shelf on his bars, the
## massage, the applause, the song and his mood.

const LEVEL := preload("res://scenes/levels/prison_vip.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: VipPlan
var requests: VipRequests


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 8
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.vip
	requests = plan.requests


func _open(kind: VipRequests.Kind) -> void:
	requests.started = true
	requests.order[requests.asked] = kind
	requests.ask_next()


func _gift(kind: VipRequests.Kind) -> Grabbable:
	for item in plan.gifts:
		if VipRequests.kind_of(item) == kind:
			return item
	return null


func test_the_seed_draws_six_different_requests() -> void:
	assert_eq(requests.order.size(), VipRequests.REQUESTS)
	var seen := {}
	for kind in requests.order:
		assert_false(seen.has(kind))
		seen[kind] = true
	assert_eq(plan.gifts.size(), 7, "every thing he can ask for is somewhere")
	for item in plan.gifts:
		assert_true(prison.inside_walls(item.global_position) or item.name == "Gift_GLASSES", item.name)


func test_nothing_until_a_cop_walks_in() -> void:
	await wait_seconds(VipRequests.FIRST + 0.5)
	assert_false(requests.started)
	assert_eq(requests.asked, 0)
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 12)
	await wait_seconds(VipRequests.FIRST + 0.5)
	assert_true(requests.started)
	assert_eq(requests.asked, 1)
	assert_true(requests.is_open(requests.order[0]))
	assert_string_starts_with(plan.rulo.said(), "VIP_ASK_")


func test_a_thing_on_the_shelf_is_his() -> void:
	_open(VipRequests.Kind.WATER)
	var water := _gift(VipRequests.Kind.WATER)
	water.global_position = plan.tray.global_position + Vector3.UP * (VipTray.HEIGHT + 0.1)
	await wait_seconds(0.8)
	assert_false(requests.is_open(VipRequests.Kind.WATER))
	assert_has(plan.received, water)
	assert_eq(requests.mood, VipRequests.MOOD_START + VipRequests.ON_TIME)
	assert_eq(requests.on_time, 1)


func test_he_doesnt_take_what_he_didnt_ask_for() -> void:
	_open(VipRequests.Kind.WATER)
	var mirror := _gift(VipRequests.Kind.MIRROR)
	mirror.global_position = plan.tray.global_position + Vector3.UP * (VipTray.HEIGHT + 0.1)
	await wait_seconds(0.5)
	assert_does_not_have(plan.received, mirror)
	assert_eq(plan.rulo.said(), "VIP_RULO_NOT_THAT")
	assert_true(requests.is_open(VipRequests.Kind.WATER))


func test_e_with_it_in_hand_puts_it_on_the_shelf() -> void:
	_open(VipRequests.Kind.PILLOW)
	var pillow := _gift(VipRequests.Kind.PILLOW)
	cop.handed(pillow)
	assert_eq(plan.tray.prompt_key(cop), "PROMPT_VIP_TRAY_PUT")
	plan.tray.use(cop)
	await wait_seconds(0.5)
	assert_has(plan.received, pillow)


func test_the_massage_is_five_presses() -> void:
	_open(VipRequests.Kind.MASSAGE)
	assert_eq(plan.tray.prompt_key(cop), "PROMPT_VIP_MASSAGE")
	for i in VipRequests.MASSAGE - 1:
		plan.tray.use(cop)
	assert_true(requests.is_open(VipRequests.Kind.MASSAGE))
	plan.tray.use(cop)
	assert_false(requests.is_open(VipRequests.Kind.MASSAGE))


func test_the_applause_takes_two_cops_together() -> void:
	var other: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	other.input_enabled = false
	prison.add_child(other)
	_open(VipRequests.Kind.APPLAUSE)
	plan.tray.use(cop)
	plan.tray.use(cop)
	assert_true(requests.is_open(VipRequests.Kind.APPLAUSE), "one cop alone isn't an applause")
	plan.tray.use(other)
	assert_false(requests.is_open(VipRequests.Kind.APPLAUSE))


func test_singing_by_his_bars_is_his_song() -> void:
	_open(VipRequests.Kind.SONG)
	cop.global_position = plan.tray.global_position + Vector3(0, -0.9, 0) - plan._into() * 0.5
	var times := int(VipRequests.SONG_TIME / VoiceChat.SING_EVERY)
	for i in times - 1:
		requests.heard_singing(cop)
	assert_true(requests.is_open(VipRequests.Kind.SONG))
	requests.heard_singing(cop)
	assert_false(requests.is_open(VipRequests.Kind.SONG))


func test_a_request_that_runs_out_is_a_tantrum() -> void:
	_open(VipRequests.Kind.GUITAR)
	requests.open[0].left = 0.05
	await wait_seconds(0.2)
	assert_false(requests.is_open(VipRequests.Kind.GUITAR))
	assert_eq(requests.late, 1)
	assert_eq(requests.mood, VipRequests.MOOD_START - VipRequests.LATE)
	assert_has(VipInmate.TANTRUMS, plan.rulo.said())


func test_his_mood_at_zero_and_the_end_of_his_requests() -> void:
	watch_signals(requests)
	requests.started = true
	requests.next_left = 999.0
	requests.mood = 10
	requests.ask_next()
	requests.open[0].left = 0.0
	await wait_seconds(0.2)
	assert_eq(requests.mood, 0)
	assert_signal_emitted(requests, "mood_zero")
	requests.asked = VipRequests.REQUESTS
	await wait_seconds(0.2)
	assert_signal_emitted(requests, "all_done")
	assert_true(requests.finished)
