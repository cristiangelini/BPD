extends GutTest

## Doña Rosa on the phone (docs/diseno/allanamiento-radio.md, step 4): she calls the reception every CALL_EVERY seconds;
## a cop who answers and stays by the phone LISTEN_SECONDS hears what don Volumen let slip, once per cop; one who walks
## off sooner hears that he's rude. Her call isn't a listener's complaint.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio() -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.case_seed = 5
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func _cop_at_phone(radio: RadioStation) -> Cop:
	var cop: Cop = radio.get_node("Cop")
	cop.global_position = radio.phone.global_position + Vector3(0, -0.9, 0.9)
	return cop


func test_she_calls_now_and_then() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_false(radio.phone.is_ringing())
	radio.rosa.next_call = 0.05
	await wait_physics_frames(6)
	assert_true(radio.rosa.calling)
	assert_true(radio.phone.is_ringing())


func test_hearing_her_out_tells_the_clue_once() -> void:
	var radio := _radio()
	radio.rosa.clue = "the archive"
	radio.rosa.clue_speech = "lo dejé en el archivo"
	await wait_physics_frames(2)
	var cop := _cop_at_phone(radio)
	watch_signals(radio.rosa)
	radio.rosa.call_now()
	radio.phone.use(cop)
	assert_eq(radio.rosa.listener, cop)
	assert_eq(radio.answered_calls, 0, "not a listener's call")
	await wait_until(func() -> bool: return radio.rosa.listener == null, DonaRosa.LISTEN_SECONDS + 2.0)
	assert_signal_emitted_with_parameters(radio.rosa, "told", ["the archive"])
	assert_eq(radio.rosa.said(), "lo dejé en el archivo")
	radio.rosa.call_now()
	radio.phone.use(cop)
	await wait_until(func() -> bool: return radio.rosa.listener == null, DonaRosa.LISTEN_SECONDS + 2.0)
	assert_signal_emit_count(radio.rosa, "told", 1)
	assert_eq(radio.rosa.said(), "ROSA_AGAIN")


func test_walking_off_is_rude() -> void:
	var radio := _radio()
	radio.rosa.clue_speech = "lo dejé en el archivo"
	await wait_physics_frames(2)
	var cop := _cop_at_phone(radio)
	radio.rosa.call_now()
	radio.phone.use(cop)
	await wait_physics_frames(3)
	cop.global_position += Vector3(4.0, 0, 0)
	await wait_physics_frames(3)
	assert_null(radio.rosa.listener)
	assert_eq(radio.rosa.said(), "ROSA_RUDE")
	assert_false(radio.rosa.has_told)


func test_her_unanswered_call_is_no_complaint() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	radio.rosa.call_now()
	radio.make_noise()
	assert_eq(radio.calls, 0, "one call at a time")
	radio.rosa._ring_left = 0.01
	await wait_physics_frames(3)
	assert_false(radio.phone.is_ringing(), "she hangs up")
	assert_eq(radio.complaints, 0)
