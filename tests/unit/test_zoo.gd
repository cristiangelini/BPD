extends GutTest

## The Zoológico Municipal on its block (escena-zoo.md, step 1; Zoo, ZooLevel).

const LEVEL := preload("res://scenes/levels/zoo.tscn")


func test_the_zoo_has_its_block_and_opens_from_play() -> void:
	var place := CityLayout.place("zoo")
	assert_false(place.is_empty())
	assert_eq(place.block, Vector2i(7, -1))
	assert_true(place.get("park", false), "it fills its block like a park")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["zoo"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=zoo"])), "zoo")
	var lot: Vector3 = place.size
	assert_eq(Vector2(lot.x, lot.z), Zoo.SIZE, "the lot is the zoo's size")


func test_the_zoo_is_a_crime_scene_place_with_its_parts() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	assert_true(zoo is CrimeScenePlace)
	assert_eq(zoo.variant, "zoo")
	var at := func(local: Vector3) -> Vector3: return zoo.to_global(local)
	assert_true(zoo.at_scene(at.call(Zoo.SIDEWALK_AT)), "the sidewalk is at the scene")
	assert_false(zoo.inside(at.call(Zoo.SIDEWALK_AT)), "but out of the fence")
	assert_eq(zoo.room(at.call(Zoo.BOOTH_AT)), "entrance")
	assert_eq(zoo.room(at.call(Zoo.ICE_CREAM_AT)), "entrance")
	assert_eq(zoo.room(at.call(Zoo.LOG_DESK_AT)), "hut")
	for i in Zoo.LOCKERS:
		assert_eq(zoo.room(at.call(Zoo.locker_at(i))), "hut", "locker %d" % i)
	assert_eq(zoo.room(at.call(Vector3(Zoo.SHOP.get_center().x, 0, Zoo.SHOP.get_center().y))), "shop")
	assert_eq(zoo.room(at.call(Zoo.TORTOISE_AT)), "reptiles")
	assert_eq(zoo.room(at.call(Zoo.ICE_AT)), "penguins", "Copito's ice floe is with the penguins")
	assert_eq(zoo.room(at.call(Zoo.TREE_AT)), "monkey")
	assert_eq(zoo.room(at.call(Zoo.MUD_AT)), "elephant")
	assert_eq(zoo.room(at.call(Vector3(-19, 0, -18))), "ostrich")
	assert_eq(zoo.room(at.call(Zoo.BOAT_AT)), "pond")
	assert_eq(zoo.room(at.call(Vector3(0, 0, -11))), "grounds", "the track round the penguins")
	assert_eq(zoo.room(at.call(Vector3(0, 0, Zoo.SIZE.y))), "", "the street is out")


func test_each_enclosure_has_its_gate_shut() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	assert_eq(zoo.gates.keys().size(), Zoo.ENCLOSURES.size())
	for kind: String in Zoo.ENCLOSURES:
		var gate := zoo.gates[kind] as StaticBody3D
		assert_almost_eq(Vector2(gate.position.x, gate.position.z),
			Vector2(Zoo.gate_at(kind).x, Zoo.gate_at(kind).z), Vector2.ONE * 0.01, "%s's gate" % kind)
		assert_ne(gate.collision_layer, 0, "%s's gate is shut" % kind)
		var sign := zoo.get_node("Sign_" + kind) as Label3D
		TranslationServer.set_locale("es")
		assert_ne(tr(sign.text), sign.text, "%s has its sign" % kind)
	assert_not_null(zoo.get_node_or_null("IceFloe"), "Copito's floe waits empty")
	assert_not_null(zoo.get_node_or_null("PenguinGlass"))


## Walks a ray from one point to another of the zoo and says whether nothing is in the way.
func _open(zoo: Zoo, from: Vector3, to: Vector3) -> bool:
	var space := zoo.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(zoo.to_global(from), zoo.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_entrance_doors_and_gates_lead_in() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	assert_true(_open(zoo, Zoo.SIDEWALK_AT + knee, Vector3(0, 0, 20) + knee), "through the entrance arch")
	assert_false(_open(zoo, Vector3(10, 0, 28) + knee, Vector3(10, 0, 24) + knee), "the fence elsewhere")
	assert_true(_open(zoo, Vector3(-11, 0, 20) + knee, Vector3(-15, 0, 20) + knee), "into the keepers' hut")
	assert_true(_open(zoo, Vector3(11, 0, 20) + knee, Vector3(15, 0, 20) + knee), "into the souvenir shop")
	assert_true(_open(zoo, Vector3(12, 0, 2) + knee, Vector3(16, 0, 2) + knee), "into the reptile house")
	assert_false(_open(zoo, Vector3(-12, 0, 0) + knee, Vector3(-16, 0, 0) + knee), "the monkey's gate is shut")
	assert_false(_open(zoo, Vector3(0, 0, 10) + knee, Vector3(0, 0, 6) + knee), "the glass keeps the penguins in")
	zoo.gates["monkey"].queue_free()
	await wait_physics_frames(2)
	assert_true(_open(zoo, Vector3(-12, 0, 0) + knee, Vector3(-16, 0, 0) + knee), "and open, the way in")


func test_the_level_puts_the_zoo_on_its_block() -> void:
	var level: ZooLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("zoo")
	assert_almost_eq(level.zoo.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.zoo.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_ZOO"), "Zoológico Municipal")
	assert_ne(tr("SIGN_ZOO_COPITO"), "SIGN_ZOO_COPITO")
