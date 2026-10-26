extends GutTest

## The museum's lasers and alarm (escena-museo.md, step 4d): a cop through a laser sets it off, the guards run to the
## bathroom's door and back, and the button on the security desk stops it (MuseumAlarm, AlarmButton).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _museum() -> Museum:
	var museum := Museum.new()
	museum.case_seed = 4
	add_child_autofree(museum)
	return museum


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 100)
	return cop


func test_the_lasers_run_between_the_pedestals() -> void:
	var alarm := _museum().alarm
	assert_eq(alarm.lasers.size(), Museum.PEDESTALS.size() - 1)
	var middle: Vector3 = (Museum.PEDESTALS[0] + Museum.PEDESTALS[1]) / 2
	assert_true(alarm.on_laser(middle))
	for at in Museum.GUARDS_AT:
		assert_false(alarm.on_laser(at), "the guards' row is clear")
	for at in MuseumClues.POLISHER_ROUTE:
		assert_false(alarm.on_laser(at), "and so is the polisher's round")


func test_a_cop_through_a_laser_sets_it_off() -> void:
	var museum := _museum()
	var cop := _cop()
	cop.global_position = museum.to_global((Museum.PEDESTALS[1] + Museum.PEDESTALS[2]) / 2 + Vector3(0, 0.1, 0))
	await wait_physics_frames(2)
	assert_true(museum.alarm.ringing)
	assert_eq(museum.director.said(), "MUSEUM_DIRECTOR_ALARM")


func test_the_guards_run_to_the_bathroom_and_come_back() -> void:
	var museum := _museum()
	var alarm := museum.alarm
	alarm.ring()
	for i in 200:
		alarm.run_guards(0.05)
	for guard in museum.guards:
		var spot := MuseumAlarm.crowd_spot(guard.index)
		assert_almost_eq(Vector2(guard.position.x, guard.position.z), Vector2(spot.x, spot.z), Vector2(0.01, 0.01))
		assert_true(museum.in_gallery(museum.to_global(guard.position)), "squeezed outside its door, not in it")
	alarm.stop()
	for i in 200:
		alarm.run_guards(0.05)
	for guard in museum.guards:
		var row := Museum.GUARDS_AT[guard.index]
		assert_almost_eq(Vector2(guard.position.x, guard.position.z), Vector2(row.x, row.z), Vector2(0.01, 0.01))


func test_it_stops_on_its_own_or_with_the_button() -> void:
	var museum := _museum()
	var alarm := museum.alarm
	alarm.ring()
	alarm.left = 0.05
	await wait_physics_frames(6)
	assert_false(alarm.ringing, "after a while")
	alarm.ring()
	var button := alarm.get_node("AlarmButton") as AlarmButton
	assert_eq(button.prompt_key(null), "PROMPT_ALARM_OFF")
	button.use(_cop())
	assert_false(alarm.ringing)
