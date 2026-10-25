class_name TalentProp
extends StaticBody3D

## A thing on the talent show's stage that hides an escape (carcel-talentos.md, step 5): the magician's box with its
## false bottom (BOX: E while someone's inside opens it) or the smoke machine (SMOKE: E while it's on turns it off).
## Its origin is on the stage's floor. Every number here is (propuesta).

signal opened(prop: TalentProp, cop: Cop)

enum Kind { BOX, SMOKE }

const BOX_SIZE := Vector3(0.9, 1.9, 0.9)
const MACHINE_SIZE := Vector3(0.5, 0.35, 0.4)
const STARS := Color(0.95, 0.85, 0.2)
const PURPLE := Color(0.35, 0.15, 0.5)
const METAL := Color(0.3, 0.3, 0.33)

var kind := Kind.BOX
## The box: someone in it, and its door shut. The machine: on.
var occupied := false
var closed := false
var running := false
## A guest's copy (step 7): the host decides.
var follower := false
var _door: MeshInstance3D


func _ready() -> void:
	add_to_group("talent_props")
	collision_layer = 8
	var size := BOX_SIZE if kind == Kind.BOX else MACHINE_SIZE
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2
	add_child(shape)
	if kind == Kind.BOX:
		add_child(CopTool.piece(CopTool.box(Vector3(size.x, size.y, size.z - 0.05)), PURPLE,
			Vector3(0, size.y / 2, -0.025)))
		for i in 3:
			add_child(CopTool.piece(CopTool.box(Vector3(0.12, 0.12, 0.01)), STARS,
				Vector3(-0.25 + i * 0.25, 1.4 - (i % 2) * 0.3, size.z / 2 + 0.005)))
		_door = CopTool.piece(CopTool.box(Vector3(size.x, size.y, 0.04)), PURPLE.lightened(0.15),
			Vector3(0, size.y / 2, size.z / 2 - 0.02))
		_door.name = "Door"
		add_child(_door)
		set_closed(false)
	else:
		add_child(CopTool.piece(CopTool.box(size), METAL, Vector3(0, size.y / 2, 0)))
		add_child(CopTool.piece(CopTool.cylinder(0.07, 0.1), Color(0.1, 0.1, 0.1),
			Vector3(0, size.y / 2, size.z / 2 + 0.05), Vector3(PI / 2, 0, 0)))


func prompt_key(_cop: Cop) -> String:
	if kind == Kind.BOX:
		return "PROMPT_OPEN_MAGIC_BOX" if closed else ""
	return "PROMPT_SMOKE_OFF" if running else ""


## E: the box's door open, or the machine off. The host's plan decides what comes of it.
func use(cop: Cop) -> void:
	if (kind == Kind.BOX and not closed) or (kind == Kind.SMOKE and not running):
		return
	opened.emit(self, cop)


## The box's door shut (with its stars) or swung open to the side.
func set_closed(shut: bool) -> void:
	closed = shut
	if not _door:
		return
	_door.visible = shut
