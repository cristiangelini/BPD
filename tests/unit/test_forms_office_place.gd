extends GutTest

## The forms office on its lot (escena-oficina.md, step 1; FormsOffice, FormsOfficeLevel).

const LEVEL := preload("res://scenes/levels/forms_office.tscn")


func test_the_office_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("office").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["office"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=office"])), "office")
	var lot: Vector3 = CityLayout.place("office").size
	assert_eq(Vector2(lot.x, lot.z), FormsOffice.SIZE, "the lot is the office's size")
	assert_eq(lot.y, FormsOffice.TALL, "and as tall")


func test_its_rooms_on_two_floors() -> void:
	var office := FormsOffice.new()
	add_child_autofree(office)
	assert_true(office is CrimeScenePlace)
	assert_eq(office.variant, "office")
	var down := Vector3.UP * 0.5
	var up := Vector3.UP * (FormsOffice.UP + 0.5)
	assert_eq(office.room_of(office.to_global(FormsOffice.COFFEE_AT + Vector3(0.5, 0.5, 0.5))), "kitchen",
		"the coffee machine is in the kitchen")
	assert_eq(office.room_of(office.to_global(FormsOffice.TIN_AT)), "kitchen", "and the cookie tin")
	assert_eq(office.room_of(office.to_global(Vector3(0, 0, -3.5) + down)), "open_space")
	assert_eq(office.room_of(office.to_global(FormsOffice.RECEPTION_AT + down)), "open_space", "with the reception")
	assert_eq(office.floor_of(office.to_global(FormsOffice.RECEPTION_AT + down)), 0)
	assert_eq(office.room_of(office.to_global(FormsOffice.MANAGER_DESK_AT + Vector3.UP)), "manager",
		"the manager's desk is upstairs in his office")
	assert_eq(office.room_of(office.to_global(FormsOffice.SAFE_AT + Vector3.UP)), "manager", "and the safe")
	assert_eq(office.floor_of(office.to_global(FormsOffice.MANAGER_DESK_AT + Vector3.UP)), 1)
	assert_eq(office.room_of(office.to_global(Vector3(-8, 0, -5) + up)), "archive")
	assert_eq(office.room_of(office.to_global(FormsOffice.MEETING_TABLE_AT + Vector3.UP)), "meeting")
	assert_eq(office.room_of(office.to_global(Vector3(5, 0, 3) + up)), "hall")
	assert_true(office.at_scene(office.to_global(Vector3(0, 0, 8.5))), "the entrance is at the scene")
	assert_false(office.inside(office.to_global(Vector3(0, 0, 8.5))), "but out of the building")
	assert_eq(office.room_of(office.to_global(Vector3(0, 0, 8.5) + down)), "")
	assert_false(office.at_scene(office.to_global(Vector3(0, 0, FormsOffice.SIZE.y))), "the street is out")
	assert_eq(office.chairs.size(), FormsOffice.DESK_COLUMNS.size() * FormsOffice.DESK_ROWS.size(),
		"a rolling chair at each of the 8 desks")
	assert_not_null(office.coffee_machine)


## Casts a ray from one point to another of the office and says whether nothing is in the way.
func _open(office: FormsOffice, from: Vector3, to: Vector3) -> bool:
	var space := office.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(office.to_global(from), office.to_global(to))
	var except: Array[RID] = []
	for chair in office.chairs:
		except.append(chair.get_rid())
	query.exclude = except
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var office := FormsOffice.new()
	add_child_autofree(office)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	var up := Vector3(0, FormsOffice.UP + 0.6, 0)
	assert_true(_open(office, Vector3(0, 0, 8.5) + knee, Vector3(0, 0, 5.5) + knee), "in by the front door")
	assert_false(_open(office, Vector3(3, 0, 8.5) + knee, Vector3(3, 0, 5.5) + knee), "the rest of the front is wall")
	assert_true(_open(office, Vector3(-4.5, 0, FormsOffice.DOOR_KITCHEN_Z) + knee,
		Vector3(-8, 0, FormsOffice.DOOR_KITCHEN_Z) + knee), "into the kitchen")
	assert_false(_open(office, Vector3(-9, 0, -1.5) + knee, Vector3(-9, 0, -5) + knee), "which has a wall")
	assert_true(_open(office, Vector3(FormsOffice.STAIR_X, 0, FormsOffice.STAIR_TOP_Z) + up,
		Vector3(FormsOffice.STAIR_X, 0, 0) + up), "off the stairs into the hall")
	assert_true(_open(office, Vector3(FormsOffice.DOOR_MANAGER_X, 0, 1) + up,
		Vector3(FormsOffice.DOOR_MANAGER_X, 0, -3) + up), "into the manager's office")
	assert_false(_open(office, Vector3(8, 0, 1) + up, Vector3(8, 0, -3) + up), "which has a wall")
	assert_true(_open(office, Vector3(FormsOffice.DOOR_ARCHIVE_X, 0, 1) + up,
		Vector3(FormsOffice.DOOR_ARCHIVE_X, 0, -3) + up), "into the archive")
	assert_true(_open(office, Vector3(-3, 0, FormsOffice.DOOR_MEETING_Z) + up,
		Vector3(-8, 0, FormsOffice.DOOR_MEETING_Z) + up), "into the meeting room")
	assert_false(_open(office, Vector3(-3, 0, 5) + up, Vector3(-8, 0, 5) + up), "which has a wall")
	assert_false(_open(office, Vector3(-9, 0, 1) + up, Vector3(-9, 0, -3) + up), "and no door to the archive")


func test_the_level_puts_the_office_on_its_lot() -> void:
	var level: FormsOfficeLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("office")
	assert_almost_eq(level.office.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.office.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_ne(tr("PLACE_OFFICE"), "PLACE_OFFICE")
	assert_ne(tr("SIGN_OFFICE_MANAGER"), "SIGN_OFFICE_MANAGER")
