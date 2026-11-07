class_name EvidenceRoom
extends RefCounted

## The evidence room (docs/diseno/escena-comisaria.md, step 1): an annex built onto the back of the station
## (StationRooms) behind the break room, on the free ground of its block, like the interrogation wing behind the office.
## A door in the break room's back wall opens on a front room with the sign-out book and the VCR the ceiling camera
## records on; past a barred wall with a gate (a CellDoor), the cage with the shelves of old cases' evidence and the
## shelf with the empty spot. Station-local coordinates, like StationRooms. Pure data. Every number here is (propuesta).

const FROM_X := 7.6
const TO_X := StationRooms.HALF_X
## From the station's back wall to the annex's back wall.
const FROM_Z := -StationRooms.HALF_Z
const TO_Z := -StationRooms.HALF_Z - 7.0
## The roof outside; inside, the same ceiling as the station.
const HEIGHT := 3.6
## The door from the break room, along the station's back wall.
const DOOR := Vector2(11.0, 12.2)
## The barred wall between the front room and the cage, and its gate, hinged at its west end.
const CAGE_Z := FROM_Z - 2.4
const GATE := Vector2(8.4, 8.4 + CellDoor.WIDTH)
const BAR_EVERY := 0.25

## The lectern with the sign-out book, by the door, facing it (+Z); the VCR table on the east wall, facing west.
const LECTERN_AT := Vector3(9.4, 0, FROM_Z - 1.1)
const VCR_AT := Vector3(TO_X - 0.55, 0, FROM_Z - 1.2)
## The shelf the stolen evidence went missing from: in the middle of the cage, its front to the gate (+Z).
const EMPTY_SHELF_AT := Vector3(11.3, 0, -13.4)
## The camera in the cage's north-east corner, up high, looking at the empty shelf.
const CAMERA_AT := Vector3(TO_X - 0.3, 2.9, CAGE_Z - 0.3)
## The sign over the door, on the break room's side.
const SIGN_AT := Vector3((DOOR.x + DOOR.y) / 2, 2.5, FROM_Z + StationRooms.WALL + 0.05)

## Furniture: [model, position, turn], as in StationRooms. Models from tools/modelgen/models/evidence_room.js, the
## camera from interrogation.js.
const FURNITURE := [
	["evidence_shelf", Vector3(9.05, 0, TO_Z + 0.55), 0.0],
	["evidence_shelf", Vector3(11.75, 0, TO_Z + 0.55), 0.0],
	["evidence_shelf", Vector3(TO_X - 0.55, 0, -13.2), -PI / 2],
	["evidence_shelf_gap", EMPTY_SHELF_AT, 0.0],
	["sign_out_lectern", LECTERN_AT, 0.0],
	["vcr_table", VCR_AT, -PI / 2],
	["security_camera", CAMERA_AT, -PI * 0.65],
]
const SOLID := {
	"evidence_shelf": Vector3(2.4, 2.2, 0.6), "evidence_shelf_gap": Vector3(2.4, 2.2, 0.6),
	"sign_out_lectern": Vector3(0.5, 1.1, 0.36), "vcr_table": Vector3(0.8, 0.9, 0.5),
}


## The annex's own outside walls (west, east and back) and its roof: [center, size].
static func shell() -> Array:
	var depth := FROM_Z - TO_Z
	var middle := (FROM_Z + TO_Z) / 2
	var wall := StationRooms.WALL
	var width := TO_X - FROM_X
	return [
		[Vector3(FROM_X + wall / 2, HEIGHT / 2, middle), Vector3(wall, HEIGHT, depth)],
		[Vector3(TO_X - wall / 2, HEIGHT / 2, middle), Vector3(wall, HEIGHT, depth)],
		[Vector3((FROM_X + TO_X) / 2, HEIGHT / 2, TO_Z + wall / 2), Vector3(width, HEIGHT, wall)],
		[Vector3((FROM_X + TO_X) / 2, HEIGHT - 0.1, middle), Vector3(width, 0.2, depth)],
	]


## The cage's barred wall, as thin [center, size] posts: over the gate they start at a bar along its top.
static func bars() -> Array:
	var posts := []
	var top := GameScale.DOOR_HEIGHT + 0.05
	var x := FROM_X + BAR_EVERY
	while x < TO_X - 0.1:
		if x < GATE.x - 0.05 or x > GATE.y + 0.05:
			posts.append([Vector3(x, StationRooms.CEILING / 2, CAGE_Z), Vector3(0.05, StationRooms.CEILING, 0.05)])
		else:
			posts.append([Vector3(x, (top + StationRooms.CEILING) / 2, CAGE_Z), Vector3(0.05, StationRooms.CEILING - top, 0.05)])
		x += BAR_EVERY
	posts.append([Vector3((GATE.x + GATE.y) / 2, top, CAGE_Z), Vector3(GATE.y - GATE.x + 0.2, 0.08, 0.08)])
	# A rail along the top, so the bars read as one wall.
	posts.append([Vector3((FROM_X + TO_X) / 2, StationRooms.CEILING - 0.1, CAGE_Z), Vector3(TO_X - FROM_X, 0.08, 0.08)])
	return posts


## A light in the front room and one in the cage, both a cold, buzzing white.
static func lights() -> Array[Vector3]:
	var y := StationRooms.CEILING - 0.4
	return [Vector3(11.3, y, FROM_Z - 1.2), Vector3(11.3, y, -14.0)]
