extends GutTest

## Don Volumen and the long song (docs/diseno/allanamiento-radio.md, step 3): he goes from the console to the archive
## filling the complaint, opening and locking its door on his way; the long song turns the "AL AIRE" light off and
## sends him to the kitchen for a coffee, his back to everything (twice; the third time he notices), and every
## listener's complaint counts.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio() -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.case_seed = 5
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_he_goes_to_the_archive_and_locks_it_behind_him() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_eq(radio.volumen.voice, "VOLUMEN")
	assert_true(radio.archive_door.locked)
	await wait_until(func() -> bool: return radio.archive_door.is_open, 6.0)
	assert_true(radio.archive_door.is_open, "he opens it on his way in")
	await wait_until(func() -> bool: return radio.to_local(radio.volumen.global_position).x > -2.5, 15.0)
	assert_lt(radio.to_local(radio.volumen.global_position).z, RadioStation.BACK_Z, "inside the archive")
	assert_false(radio.archive_door.is_open, "he shut it")
	assert_true(radio.archive_door.locked, "and locked it")


func test_the_long_song_sends_him_for_a_coffee_off_air() -> void:
	var radio := _radio()
	radio.volumen.fix_time = 1.0
	await wait_physics_frames(2)
	radio.record_player.print_copies()
	assert_false(radio.on_air, "the light goes off")
	radio.mic.use(radio.get_node("Cop"))
	assert_eq(radio.calls, 0, "off air nobody hears the microphone")
	await wait_until(func() -> bool: return radio.volumen.is_fixing(), 30.0)
	assert_true(radio.volumen.is_fixing(), "making his coffee")
	var at := radio.to_local(radio.volumen.global_position)
	assert_gt(at.x, RadioStation.KITCHEN_X0, "in the kitchen")
	assert_false(radio.volumen.can_see(radio.to_global(Vector3(6.5, 1.0, 2.0))), "his back to the door")
	await wait_until(func() -> bool: return not radio.volumen.is_fixing(), 5.0)
	assert_true(radio.on_air, "back on air")
	assert_gt(radio.record_player.rest_left, 0.0, "the player rests")


func test_the_third_song_he_notices() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	for i in RadioRecordPlayer.TRICKS:
		radio.record_player.print_copies()
		radio.record_player.fix()
		radio.record_player.rest_left = 0.0
	var before := radio.volumen.complaint
	radio.record_player.print_copies()
	assert_false(radio.record_player.is_jammed, "he doesn't go")
	assert_true(radio.on_air)
	assert_almost_eq(radio.volumen.complaint, before + RadioStation.NOTICED, 0.01)


func test_a_listener_and_the_cracked_window_go_on_his_complaint() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	radio.make_noise()
	radio._process(RadioStation.CALL_WAIT + 0.5)
	assert_almost_eq(radio.volumen.complaint, RadioStation.LISTENER, 0.01)
	radio.volumen.global_position = radio.to_global(Vector3(-3.4, RadioStation.FLOOR_TOP, 7.0))
	radio.volumen.look_at(radio.to_global(Vector3(-3.4, 1.5, RadioStation.FRONT_Z)), Vector3.UP, true)
	radio.break_glass()
	assert_almost_eq(radio.volumen.complaint, RadioStation.LISTENER + RadioStation.SAW_GLASS, 0.01)
