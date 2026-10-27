extends GutTest

## The open city (docs/diseno/ciudad.md, step 1): every place has a lot, nothing overlaps or blocks a street,
## and the patrol car drives along the avenue.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")
const RAID_PLACES: Array[String] = [
	"grandpa", "bakery", "pet_salon", "hardware", "doll_factory", "insurance", "cake_lab", "apartments", "hotel", "gym",
]


func _lots() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for p: Dictionary in CityLayout.PLACES:
		rects.append(CityLayout.footprint(p.block, p.side, p.along, p.size))
	for lot: Dictionary in CityLayout.fillers():
		rects.append(CityLayout.footprint(lot.block, lot.side, lot.along, lot.size))
	return rects


func test_the_station_and_the_ten_raid_places_are_in_the_city() -> void:
	assert_false(CityLayout.place("station").is_empty())
	for id in RAID_PLACES:
		assert_false(CityLayout.place(id).is_empty(), "%s should have a lot" % id)
	assert_false(CityLayout.place("grandpa_club").is_empty(), "the infiltration's club too")
	assert_false(CityLayout.place("chapel").is_empty(), "and the choir's chapel")
	assert_false(CityLayout.place("bank").is_empty(), "and the bank to rob")
	assert_false(CityLayout.place("prison").is_empty(), "and the prison")
	assert_false(CityLayout.place("gas_station").is_empty(), "and the transfer's gas station")
	assert_false(CityLayout.place("market").is_empty(), "and the covered market")
	assert_false(CityLayout.place("circus").is_empty(), "and the circus")
	assert_false(CityLayout.place("mime_theater").is_empty(), "and the mimes' theater")
	assert_false(CityLayout.place("party_hall").is_empty(), "and the costume party's hall")
	assert_false(CityLayout.place("school").is_empty(), "and the thieves' school")
	assert_false(CityLayout.place("restaurant").is_empty(), "and the restaurant")
	assert_false(CityLayout.place("chess").is_empty(), "and the chess club")
	assert_false(CityLayout.place("biker").is_empty(), "and the biker bar")
	assert_false(CityLayout.place("auction").is_empty(), "and the auction house")
	assert_false(CityLayout.place("bridge_park").is_empty(), "and the park with the canal")
	assert_false(CityLayout.place("school_visit").is_empty(), "and the school the deputy visits")
	assert_false(CityLayout.place("football_pitch").is_empty(), "and the football pitch")
	assert_false(CityLayout.place("tv_studio").is_empty(), "and the TV channel")
	assert_false(CityLayout.place("museum").is_empty(), "and the museum")
	assert_false(CityLayout.place("wrong_house").is_empty(), "and the twin houses of the wrong house")
	assert_false(CityLayout.place("airport").is_empty(), "and the airport")
	assert_false(CityLayout.place("planetarium").is_empty(), "and the planetarium")
	assert_eq(CityLayout.PLACES.size(), RAID_PLACES.size() + 23)


func test_no_two_lots_overlap() -> void:
	var rects := _lots()
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			assert_false(rects[i].intersects(rects[j]), "lots %d and %d overlap" % [i, j])


func test_every_lot_stays_inside_its_block_behind_the_sidewalk() -> void:
	var all: Array = CityLayout.PLACES + CityLayout.fillers()
	for lot: Dictionary in all:
		var center := CityLayout.block_center(lot.block)
		var inner := CityLayout.BLOCK - CityLayout.SIDEWALK * 2
		var block := Rect2(Vector2(center.x, center.z) - Vector2.ONE * inner / 2, Vector2.ONE * inner)
		var rect := CityLayout.footprint(lot.block, lot.side, lot.along, lot.size)
		assert_true(block.grow(0.01).encloses(rect), "a lot in block %s sticks out" % lot.block)


func test_every_door_faces_a_street() -> void:
	for p: Dictionary in CityLayout.PLACES:
		var door := CityLayout.door_of(p.id) + CityLayout.side_normal(p.side) * (CityLayout.SIDEWALK + 1.0)
		var on_street := false
		for k in range(CityLayout.WEST, CityLayout.EAST + 1):
			on_street = on_street or absf(door.x - CityLayout.street_x(k)) < CityLayout.STREET / 2
		for k in range(CityLayout.NORTH, CityLayout.SOUTH + 1):
			on_street = on_street or absf(door.z - CityLayout.street_z(k)) < CityLayout.STREET / 2
		assert_true(on_street, "%s should open to a street" % p.id)


func test_signs_and_street_names_are_translated() -> void:
	var keys: Array = CityLayout.PLACES.map(func(p: Dictionary) -> String: return p.sign)
	keys.append_array(CityLayout.STREETS_EW + CityLayout.STREETS_NS)
	assert_eq(CityLayout.STREETS_EW.size(), CityLayout.ROWS - 1)
	assert_eq(CityLayout.STREETS_NS.size(), CityLayout.COLUMNS - 1)
	TranslationServer.set_locale("es")
	for key: String in keys:
		assert_ne(tr(key), key, "%s needs a text" % key)


func test_the_patrol_car_drives_down_the_avenue() -> void:
	var city: City = CITY_SCENE.instantiate()
	city.traffic = false
	add_child_autofree(city)
	var cop: Cop = city.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	var car: PatrolCar = city.get_node("PatrolCar")
	await wait_physics_frames(10)
	cop.global_position = car.to_global(Vector3(2, 0, 0.55))
	assert_eq(car.enter(cop), 0, "standing by the driver's door")
	var start := car.global_position
	for i in 240:
		car.drive(1.0, 0.0, false)
		await wait_physics_frames(1)
	assert_gt(car.global_position.distance_to(start), 30.0, "four seconds of gas should cover the block")
	assert_lt(absf(car.global_position.z - start.z), 2.0, "the street is clear, the car keeps straight")
