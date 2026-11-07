extends GutTest

## The Correo Central on its lot (escena-correo.md, step 1; PostOffice, PostOfficeLevel).

const LEVEL := preload("res://scenes/levels/post_office.tscn")


func test_the_post_office_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("post_office").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["post_office"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=post_office"])), "post_office")
	var lot: Vector3 = CityLayout.place("post_office").size
	assert_eq(Vector2(lot.x, lot.z), PostOffice.SIZE, "the lot is the post office's size")


func test_the_post_office_is_a_crime_scene_place_with_its_rooms() -> void:
	var post_office := PostOffice.new()
	add_child_autofree(post_office)
	assert_true(post_office is CrimeScenePlace)
	assert_eq(post_office.variant, "post_office")
	var at := func(local: Vector3) -> Vector3: return post_office.to_global(local)
	assert_true(post_office.at_scene(at.call(PostOffice.MAILBOX_AT)), "the mailbox is at the scene")
	assert_false(post_office.inside(at.call(PostOffice.MAILBOX_AT)), "but out on the sidewalk")
	assert_eq(post_office.room(at.call(PostOffice.SCALE_AT)), "counter")
	assert_eq(post_office.room(at.call(PostOffice.RETURNS_AT)), "counter")
	assert_eq(post_office.room(at.call(PostOffice.FRAME_AT + Vector3(0, 0, 0.1))), "counter", "the frame hangs in the hall")
	assert_eq(post_office.room(at.call(PostOffice.box_at(0))), "boxes")
	assert_eq(post_office.room(at.call(PostOffice.MACHINE_AT)), "sorting")
	for sack: Vector3 in PostOffice.SACKS_AT:
		assert_eq(post_office.room(at.call(sack)), "sorting")
	assert_eq(post_office.room(at.call(PostOffice.SHELVES_AT)), "depot")
	assert_eq(post_office.room(at.call(PostOffice.SAFE_AT)), "office")
	assert_eq(post_office.room(at.call(PostOffice.DESK_AT)), "office")
	assert_false(post_office.at_scene(at.call(Vector3(0, 0, PostOffice.SIZE.y))), "the street is out")


func test_the_post_boxes_and_six_have_a_route() -> void:
	var post_office := PostOffice.new()
	add_child_autofree(post_office)
	assert_eq(PostOffice.ROUTE_BOXES.size(), 6)
	assert_eq(PostOffice.ROUTE_BOXES.keys(), PostOffice.ROUTE_COLORS.keys(), "one box for each route")
	for i in PostOffice.BOX_ROWS * PostOffice.BOX_COLUMNS:
		var box := post_office.get_node("Box%d" % i) as Node3D
		assert_eq(post_office.room(box.global_position), "boxes", "box %d is in the boxes room" % i)
		assert_gt(box.position.y, 0.3, "box %d is off the floor" % i)
		var has_route := PostOffice.ROUTE_BOXES.values().has(i)
		assert_eq(box.get_node_or_null("Route") != null, has_route, "box %d's route" % i)
	for i in PostOffice.SACKS_AT.size():
		assert_not_null(post_office.get_node_or_null("Sack%d" % i))
	assert_not_null(post_office.get_node_or_null("StampFrame"), "the empty frame hangs behind the counter")
	assert_not_null(post_office.get_node_or_null("SafeDoor"), "and the safe is open")


## Walks a ray at knee height from one point to another of the post office and says whether nothing is in the way.
func _open(post_office: PostOffice, from: Vector3, to: Vector3) -> bool:
	var space := post_office.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(post_office.to_global(from), post_office.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var post_office := PostOffice.new()
	add_child_autofree(post_office)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	assert_true(_open(post_office, Vector3(0, 0, 13.5) + knee, Vector3(0, 0, 5.0) + knee), "through the front door")
	assert_true(_open(post_office, Vector3(4, 0, PostOffice.DOOR_BOXES_Z) + knee,
		Vector3(10, 0, PostOffice.DOOR_BOXES_Z) + knee), "into the boxes room")
	assert_true(_open(post_office, Vector3(PostOffice.DOOR_SORTING_X, 0, 1.0) + knee,
		Vector3(PostOffice.DOOR_SORTING_X, 0, -2.0) + knee), "into the sorting room")
	assert_true(_open(post_office, Vector3(5, 0, PostOffice.DOOR_DEPOT_Z) + knee,
		Vector3(10, 0, PostOffice.DOOR_DEPOT_Z) + knee), "into the depot")
	assert_true(_open(post_office, Vector3(5, 0, PostOffice.DOOR_OFFICE_Z) + knee,
		Vector3(9, 0, PostOffice.DOOR_OFFICE_Z) + knee), "into the office")
	assert_true(_open(post_office, Vector3(-14, 0, 5.2) + knee, Vector3(-14, 0, 0.8) + knee),
		"round the counter's west end to the staff's side")
	assert_false(_open(post_office, Vector3(10, 0, -3.0) + knee, Vector3(10, 0, -7.0) + knee),
		"a wall between the depot and the office")


func test_the_level_puts_the_post_office_on_its_lot() -> void:
	var level: PostOfficeLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("post_office")
	assert_almost_eq(level.post_office.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.post_office.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_POST_OFFICE"), "Correo Central")
