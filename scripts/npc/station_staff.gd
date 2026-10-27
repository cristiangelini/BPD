class_name StationStaff
extends StaticBody3D

## The station's people in its crime scene (docs/diseno/escena-comisaria.md, step 2): five coworkers in the same blue
## uniform, cap and regulation mustache as the cops, told apart by the name plate on their chest (it reads only up
## close) and where they work, and el Chancho, the prisoner in cell 1 who saw everything. The sixth coworker is the
## armero, who stays behind his counter (Armero). E on any of them gets one of their lines, a different one each time.
## What they do in the case (their traits, the false alibi, the cleaner who wipes clues, the witness) comes in steps 3
## and 4. Every number here is (propuesta).

## Who they can be: their model, how many lines they have (STAFF_<WHO>_LINE_<n>) and where they stand in the station
## (station-local, StationRooms and EvidenceRoom) with their turn.
const WHO := {
	"ronquido": {"model": "res://assets/models/npc_cabo_ronquido.glb", "lines": 4, "at": Vector3(-3.6, 0, 7.6), "turn": PI / 2},
	"sellito": {"model": "res://assets/models/npc_oficial_sellito.glb", "lines": 4, "at": Vector3(3.6, 0, 7.6), "turn": -PI / 2},
	"mopa": {"model": "res://assets/models/npc_don_mopa.glb", "lines": 4, "at": Vector3(8.0, 0, -6.0), "turn": PI / 2},
	"fritanga": {"model": "res://assets/models/npc_dona_fritanga.glb", "lines": 4, "at": Vector3(13.4, 0, -7.4), "turn": 0.0},
	"polilla": {"model": "res://assets/models/npc_polilla.glb", "lines": 4, "at": Vector3(13.2, 0, -10.2), "turn": -PI / 2},
	"chancho": {"model": "res://assets/models/npc_chancho.glb", "lines": 4, "at": Vector3(7.4, 0, 3.6), "turn": 0.0},
}
## The coworkers, in the case's order (the armero apart); el Chancho is not a suspect.
const COWORKERS: Array[String] = ["ronquido", "sellito", "mopa", "fritanga", "polilla"]
## Where the name plate sits on the model's chest.
const PLATE_AT := Vector3(-0.12, 0.9, 0.315)

var who := "ronquido"
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


## Puts the five coworkers and el Chancho in their places in the station's `root` (the station's building node).
static func spawn_all(root: Node3D) -> Array[StationStaff]:
	var people: Array[StationStaff] = []
	for id: String in WHO:
		var person := StationStaff.new()
		person.who = id
		person.name = "Staff_" + id
		person.position = WHO[id].at
		person.rotation.y = WHO[id].turn
		root.add_child(person)
		people.append(person)
	return people


func _ready() -> void:
	add_to_group("station_staff")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = (load(WHO[who].model) as PackedScene).instantiate()
	add_child(_model)
	var teeth := part("teeth")
	if teeth:
		teeth.visible = false
	if who != "chancho":
		var plate := Label3D.new()
		plate.name = "Plate"
		plate.text = name_key()
		plate.font_size = 32
		plate.pixel_size = 0.0007
		plate.modulate = Color(0.1, 0.1, 0.15)
		plate.outline_size = 0
		plate.position = PLATE_AT
		plate.rotation = Vector3(-0.45, -0.3, 0)
		add_child(plate)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func name_key() -> String:
	return "STAFF_NAME_" + who.to_upper()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STAFF_" + who.to_upper()


## E on them: their next line.
func use(_cop: Cop) -> void:
	say(line_key(_lines_said))
	_lines_said += 1


## The key of their line number n (it goes round).
func line_key(n: int) -> String:
	return "STAFF_%s_LINE_%d" % [who.to_upper(), n % int(WHO[who].lines)]


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of their model by name (teeth, props).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
