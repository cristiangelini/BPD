class_name SleepwalkerRig
extends HotelRig

## The sleepwalker (hotel-allanamiento.md, "El sonámbulo"): a guest walks the neighborhood in his sleep and comes back
## with other people's things; don Bostezo keeps them in a lost-and-found box and sells them. The box is the main
## evidence, hidden like the extras (the neighborhood's list of what's missing and the guest's sleep mask). The story's
## own clue: muddy slipper prints from the front door to wherever the box is hidden. The guest walks the corridor
## (Sleepwalker); waking him makes him shout, which wakes don Bostezo and adds SHOUT to the complaint. Every number
## here is (propuesta).

const SHOUT := 10.0
## The trail: from just inside the front door to the foot of the stairs, then from their top along the corridor.
const DOOR := Vector3(Hotel.DOOR_FRONT_X, Hotel.FLOOR_TOP, 6.3)
const STAIR_FOOT := Vector3(Hotel.STAIR_X, Hotel.FLOOR_TOP, Hotel.STAIR_FOOT_Z + 0.5)
const STAIR_TOP := Vector3(Hotel.STAIR_X, Hotel.UP, Hotel.STAIR_TOP_Z - 0.3)
const STEP := 0.45
const SEES_STEPS := 1.5
const MUD := Color(0.52, 0.38, 0.2)

var sleepwalker: Sleepwalker
var steps: Array[Vector3] = []
var steps_seen := false
var _material: StandardMaterial3D


func setup(place: HotelRaid) -> void:
	super.setup(place)
	sleepwalker = Sleepwalker.new()
	sleepwalker.name = "Sleepwalker"
	sleepwalker.position = Vector3(Sleepwalker.WEST_X, Hotel.UP, Sleepwalker.WALK_Z)
	place.add_child(sleepwalker)
	sleepwalker.woke.connect(func(_at: Vector3) -> void: place.concierge.shout_heard(SHOUT))
	_material = StandardMaterial3D.new()
	_material.albedo_color = MUD
	var box_at: Vector3 = HotelRaid.SPOTS[place.hidden_spots[0]].at
	var corners := trail_to(box_at)
	for i in range(1, corners.size()):
		_prints(corners[i - 1], corners[i])


## The corners of the slipper trail from the front door to `at`: straight across the lobby, or up the stairs, along
## the corridor and in through the door of the room it's in.
static func trail_to(at: Vector3) -> Array[Vector3]:
	if at.y < Hotel.UP - 0.5:
		return [DOOR, at]
	var corners: Array[Vector3] = [DOOR, STAIR_FOOT, STAIR_TOP, Vector3(STAIR_TOP.x, Hotel.UP, 0.0)]
	if at.x < Hotel.SUITE_X:
		corners.append(Vector3(Hotel.SUITE_X + 0.4, Hotel.UP, Hotel.DOOR_SUITE_Z))
		corners.append(Vector3(Hotel.SUITE_X - 0.4, Hotel.UP, Hotel.DOOR_SUITE_Z))
	for number: int in Hotel.ROOMS:
		var room: Dictionary = Hotel.ROOMS[number]
		var north: bool = room.side == "n"
		if at.x > room.x0 and at.x < room.x1 and (at.z < -Hotel.CORRIDOR if north else at.z > Hotel.CORRIDOR):
			corners.append(Vector3(room.door, Hotel.UP, 0.0))
			corners.append(Vector3(room.door, Hotel.UP, -Hotel.CORRIDOR if north else Hotel.CORRIDOR))
	corners.append(Vector3(at.x, Hotel.UP, at.z))
	return corners


func _physics_process(_delta: float) -> void:
	if steps_seen:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		for step in steps:
			if step.distance_to(cop.global_position) < SEES_STEPS:
				steps_seen = true
				hotel_raid.raid.add_clue(tr("CLUE_SLEEPWALKER_STEPS"))
				return


## Muddy slipper prints from `from` to `to`, left and right, pointing the way.
func _prints(from: Vector3, to: Vector3) -> void:
	var flat := Vector3(to.x - from.x, 0, to.z - from.z)
	if flat.length() < 0.1:
		return
	var ahead := flat.normalized()
	var aside := ahead.cross(Vector3.UP) * 0.1
	var count := int(flat.length() / STEP)
	for i in count:
		var at := from + ahead * (i * STEP) + aside * (1.0 if i % 2 == 0 else -1.0)
		at.y = from.y + 0.012
		var print_mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.11, 0.004, 0.27)
		print_mesh.mesh = box
		print_mesh.material_override = _material
		print_mesh.position = at
		print_mesh.rotation.y = atan2(ahead.x, ahead.z)
		hotel_raid.add_child(print_mesh)
		steps.append(at)
