extends GutTest

## The radio's "AL AIRE" light, microphone and listeners' phone (docs/diseno/allanamiento-radio.md, step 2): on air, a
## loud hit near the microphone, something that breaks or a cop speaking into the microphone rings the phone; a call
## nobody answers in CALL_WAIT seconds becomes a listener's complaint, and off air nothing goes out.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio() -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.case_seed = 5
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_speaking_on_air_rings_the_phone() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var cop: Cop = radio.get_node("Cop")
	assert_eq(radio.mic.prompt_key(cop), "PROMPT_RADIO_MIC")
	watch_signals(radio)
	radio.mic.use(cop)
	assert_true(radio.phone.is_ringing())
	assert_signal_emitted(radio, "went_on_air")
	radio.mic.use(cop)
	assert_eq(radio.calls, 1, "one call at a time")


func test_an_unanswered_call_is_a_complaint() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	watch_signals(radio)
	radio.make_noise()
	radio._process(RadioStation.CALL_WAIT - 1.0)
	assert_eq(radio.complaints, 0)
	radio._process(1.5)
	assert_eq(radio.complaints, 1)
	assert_signal_emitted(radio, "listener_complained")
	assert_false(radio.phone.is_ringing(), "the phone stops ringing")


func test_answering_the_call_avoids_the_complaint() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	radio.make_noise()
	radio.phone.use(radio.get_node("Cop"))
	radio._process(RadioStation.CALL_WAIT + 1.0)
	assert_eq(radio.complaints, 0)
	assert_eq(radio.phone.answers, 1)


func test_off_air_nothing_goes_out() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	radio.set_on_air(false)
	assert_false(radio.get_node("Built/OnAirSign").visible)
	radio.mic.use(radio.get_node("Cop"))
	radio.break_glass()
	assert_eq(radio.calls, 0)
	assert_false(radio.phone.is_ringing())


func test_a_hit_near_the_mic_goes_on_air() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var prop := ClubEvidence.make_item("Thrown", RadioStation.PLAYER_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	radio.add_child(prop)
	prop.position = Vector3(-7.0, 1.5, 1.0)
	prop.linear_velocity = Vector3(0, 0, -4.0)
	await wait_physics_frames(6)
	assert_eq(radio.calls, 1)
	assert_true(radio.phone.is_ringing())
