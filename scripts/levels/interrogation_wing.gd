class_name InterrogationWing
extends RefCounted

## The interrogation wing (docs/diseno/interrogatorio.md, "Dónde pasa"): a movie interrogation room, built onto the
## back of the station (StationRooms) on the free ground of its block. A door in the back wall of the comisario's office
## opens on a hall; off the hall, the interrogation room (east) and the observation room (west), with the one-way mirror
## in the wall between them. Station-local coordinates, like StationRooms. Pure data. Every number here is (propuesta).

const HALF_X := 7.0
## From the station's back wall to the wing's back wall.
const FROM_Z := -StationRooms.HALF_Z
const TO_Z := -StationRooms.HALF_Z - 9.0
## The roof outside; inside, the same ceiling as the station.
const HEIGHT := 3.6
## The hall runs along the station's back wall, 2 m deep.
const HALL_Z := FROM_Z - 2.0
## The mirror wall, between the observation room (west) and the interrogation room (east).
const MIRROR_X := -1.0
## Doors: from the office to the hall (in the station's back wall), and from the hall to each room.
const OFFICE_DOOR := Vector2(2.6, 3.8)
const OBSERVATION_DOOR := Vector2(-4.6, -3.4)
const ROOM_DOOR := Vector2(4.4, 5.6)
## The one-way mirror along the mirror wall, from 1 m up to the door lintels.
const MIRROR := Vector2(-16.5, -12.5)
const MIRROR_BOTTOM := 1.0

## Where the suspect sits, facing the door side (+Z), and where the lamp hangs over the table.
const SUSPECT_AT := Vector3(3.0, 0, -15.4)
const LAMP_AT := Vector3(3.0, StationRooms.CEILING, -14.6)

## Furniture: [model, position, turn], as in StationRooms. Models from tools/modelgen/models/interrogation.js.
const FURNITURE := [
	["interrogation_table", Vector3(3.0, 0, -14.6), 0.0],
	["interrogation_chair", SUSPECT_AT, 0.0],
	["interrogation_chair", Vector3(2.4, 0, -13.6), PI],
	["interrogation_chair", Vector3(3.6, 0, -13.6), PI],
	["hanging_lamp", LAMP_AT, 0.0],
	["wall_clock", Vector3(3.0, 2.4, TO_Z + 0.12), 0.0],
	["security_camera", Vector3(HALF_X - 0.2, 2.8, TO_Z + 0.2), -PI * 0.28],
	["recording_desk", Vector3(MIRROR_X - 0.6, 0, -14.5), -PI / 2],
	["interrogation_chair", Vector3(MIRROR_X - 1.8, 0, -13.9), -PI / 2],
	["interrogation_chair", Vector3(MIRROR_X - 1.8, 0, -15.1), -PI / 2],
	["station_coffee", Vector3(-HALF_X + 0.6, 0, TO_Z + 0.5), 0.0],
]
## The "no smoking" sign on the interrogation room's east wall, facing the room.
const SIGN_AT := Vector3(HALF_X - StationRooms.WALL - 0.03, 2.0, -14.5)
## Footprints of what you bump into; the lamp, the clock and the camera are up high.
const SOLID := {
	"interrogation_table": Vector3(1.8, 0.76, 0.9), "interrogation_chair": Vector3(0.5, 0.9, 0.5),
	"recording_desk": Vector3(1.6, 0.76, 0.7),
}


## The wing's own outside walls (west, east and back) and its roof: [center, size].
static func shell() -> Array:
	var depth := FROM_Z - TO_Z
	var middle := (FROM_Z + TO_Z) / 2
	var wall := StationRooms.WALL
	return [
		[Vector3(-HALF_X + wall / 2, HEIGHT / 2, middle), Vector3(wall, HEIGHT, depth)],
		[Vector3(HALF_X - wall / 2, HEIGHT / 2, middle), Vector3(wall, HEIGHT, depth)],
		[Vector3(0, HEIGHT / 2, TO_Z + wall / 2), Vector3(HALF_X * 2, HEIGHT, wall)],
		[Vector3(0, HEIGHT - 0.1, middle), Vector3(HALF_X * 2, 0.2, depth)],
	]


## Inside walls: the hall's wall with the two doors, and the mirror wall with its window left open.
static func walls() -> Array:
	var pieces := []
	StationRooms.run(pieces, "x", HALL_Z, -HALF_X, HALF_X, [OBSERVATION_DOOR, ROOM_DOOR])
	StationRooms.run(pieces, "z", MIRROR_X, TO_Z, HALL_Z, [MIRROR])
	var length := MIRROR.y - MIRROR.x
	pieces.append([Vector3(MIRROR_X, MIRROR_BOTTOM / 2, (MIRROR.x + MIRROR.y) / 2),
		Vector3(StationRooms.WALL, MIRROR_BOTTOM, length)])
	return pieces


## The mirror pane: [center, size], filling the window.
static func mirror() -> Array:
	var bottom := MIRROR_BOTTOM
	var top := GameScale.DOOR_HEIGHT
	return [Vector3(MIRROR_X, (bottom + top) / 2, (MIRROR.x + MIRROR.y) / 2), Vector3(0.04, top - bottom, MIRROR.y - MIRROR.x)]


## A dim light in the hall and in the observation room; the interrogation room only has the lamp over the table.
static func lights() -> Array[Vector3]:
	var y := StationRooms.CEILING - 0.4
	return [Vector3(-3.0, y, FROM_Z - 1.0), Vector3(-4.0, y, -15.0)]
