extends GutTest

## "Radio La Antena Loca" as a place to raid (docs/diseno/allanamiento-radio.md, step 1): the radio on its lot, the
## locked archive with its key in the till, the studio's window and the archive's records that break when something
## hits them fast, the stair to the roof and the antenna, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func _prop(radio: RadioStation, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", RadioRecordPlayer.MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	radio.add_child(prop)
	prop.position = at
	prop.linear_velocity = velocity
	return prop


func test_the_radio_has_its_door_and_spots() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_true(radio.archive_door.locked)
	assert_true(radio.till.has_key, "the archive's key is in the reception's till")
	assert_eq(RadioStation.SPOTS.size(), 12)
	assert_eq(RadioStation.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in RadioStation.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), RadioStation.HALF_X, spot.id)
		assert_lt(absf(at.z), RadioStation.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_radio_stands_on_its_lot() -> void:
	var radio := _radio()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("radio").size.x > 0.0)
	assert_eq((radio.get_node("City") as Node3D).transform, CityLayout.anchor("radio"))
	assert_eq(PlaceDraw.PLACES.radio, "res://scenes/levels/radio_station.tscn")


func test_the_spots_hold_something_dropped_on_them() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	for item: Evidence in radio.hidden:
		item.freeze = true
		item.position = Vector3(0, -20, 0)
	var props: Array[Grabbable] = []
	for spot: Dictionary in RadioStation.SPOTS:
		props.append(_prop(radio, spot.at + Vector3(0, 0.3, 0), Vector3.ZERO))
	await wait_physics_frames(60)
	for i in props.size():
		var spot: Dictionary = RadioStation.SPOTS[i]
		assert_almost_eq(props[i].position.y, spot.at.y + 0.15, 0.2, "%s holds it" % spot.id)


func test_the_stair_reaches_the_roof() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var cop: Cop = radio.get_node("Cop")
	cop.position = RadioStation.STAIR_FOOT + Vector3(0, 0.2, 0.5)
	for i in 120:
		cop.velocity = Vector3(0, cop.velocity.y, -GameScale.WALK_SPEED)
		cop.move_and_slide()
		await wait_physics_frames(1)
	assert_almost_eq(cop.position.y, RadioStation.ROOF_TOP, 0.3, "up on the roof")


func test_something_thrown_hard_at_the_studio_window_cracks_it_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var window := Vector3((RadioStation.WINDOW_X0 + RadioStation.WINDOW_X1) / 2, 1.5, RadioStation.FRONT_Z)
	_prop(radio, window + Vector3(0, 0, 3.0), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(radio.glass_cracked)
	assert_eq(radio.fines, RadioStation.GLASS_FINE)
	radio.break_glass()
	assert_eq(radio.fines, RadioStation.GLASS_FINE, "only once")


func test_a_fast_prop_at_the_shelves_breaks_records_up_to_five() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	_prop(radio, Vector3(-4.0, 1.4, RadioStation.SHELF_ROWS[0] + 1.6), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(radio.records_broken, 0, "a slow one doesn't")
	_prop(radio, Vector3(-4.0, 1.4, RadioStation.SHELF_ROWS[0] + 1.8), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_eq(radio.records_broken, 1)
	assert_eq(radio.fines, RadioStation.RECORD_FINE)
	for i in 8:
		radio.drop_record(radio.to_global(Vector3(-4.0, 1.0, RadioStation.SHELF_ROWS[1])))
	assert_eq(radio.records_broken, RadioStation.MAX_RECORDS)
	assert_eq(radio.fines, RadioStation.RECORD_FINE * RadioStation.MAX_RECORDS)


func test_the_till_key_opens_the_archive() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var cop: Cop = radio.get_node("Cop")
	radio.till.use(cop)
	assert_true(cop.has_key)
	radio.archive_door.use(cop)
	assert_false(radio.archive_door.locked)
