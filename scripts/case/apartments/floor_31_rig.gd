class_name Floor31Rig
extends ApartmentsRig

## The floor that doesn't exist (edificio.md, "El piso 31"): Mr. Bellini keeps the key of floor 31 on his study's
## desk. In the elevator, a "31" button is taped over (the story's clue). With the key turned in the keyhole under the
## buttons, the button takes the car up to the machine room on the roof, where the box of stolen paintings waits. The
## key is the main evidence; the box is an extra that only that ride reaches. Every number here is (propuesta).

signal opened_31

## The elevator's stop at the machine room.
const SECRET_STOP := 2
const KEY_SCENE := preload("res://scenes/props/floor_key.tscn")
const BOX_SCENE := preload("res://scenes/props/paintings_box.tscn")
const BOX_HALF_HEIGHT := 0.32
## On the study's desk.
const KEY_AT := ApartmentTower.DESK_AT + Vector3(0.3, ApartmentTower.DESK_SIZE.y + 0.02, 0.0)
## In the machine room, to one side of the elevator's door.
const BOX_AT := Vector3(-1.9, ApartmentTower.ROOF_Y + 0.02, -2.4)
## The panel on the car's right wall, in the car's space: the button over the keyhole.
const BUTTON_AT := Vector3(0.83, 1.25, 0.45)
const KEYHOLE_AT := Vector3(0.83, 1.0, 0.45)
const TAPE := Color(0.85, 0.8, 0.6)

var key: Evidence
var box: Evidence
var button: Floor31Button
var keyhole: ElevatorKeyhole
var opened := false
var _tape: MeshInstance3D


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	key = KEY_SCENE.instantiate()
	key.position = KEY_AT
	place.add_child(key)
	place.main = key
	box = BOX_SCENE.instantiate()
	box.position = BOX_AT + Vector3.UP * (BOX_HALF_HEIGHT + 0.01)
	place.add_child(box)
	place.extras.append(box)
	button = Floor31Button.new()
	button.rig = self
	button.size = Vector3(0.06, 0.12, 0.12)
	button.prompt = "PROMPT_TAPED_BUTTON"
	button.text = "CLUE_TAPED_BUTTON"
	button.position = BUTTON_AT
	button.add_child(_mesh(Vector3(0.03, 0.1, 0.1), Color(0.95, 0.8, 0.3)))
	_tape = _mesh(Vector3(0.035, 0.12, 0.12), TAPE)
	button.add_child(_tape)
	place.elevator.add_child(button)
	button.read.connect(func(text: String) -> void: tower.raid.add_clue(tr(text)))
	keyhole = ElevatorKeyhole.new()
	keyhole.rig = self
	var shape := CollisionShape3D.new()
	var hole := BoxShape3D.new()
	hole.size = Vector3(0.06, 0.1, 0.1)
	shape.shape = hole
	keyhole.add_child(shape)
	keyhole.add_child(_mesh(Vector3(0.03, 0.08, 0.08), Color(0.3, 0.3, 0.32)))
	keyhole.position = KEYHOLE_AT
	place.elevator.add_child(keyhole)


## The key turns: the tape comes off the "31" button and it works.
func open(cop: Cop) -> void:
	if opened:
		return
	opened = true
	_tape.visible = false
	cop.show_hint("HINT_FLOOR_31_OPEN")
	tower.raid.add_clue(tr("CLUE_FLOOR_31_OPEN"))
	opened_31.emit()


func _mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	look.mesh = mesh
	return look
