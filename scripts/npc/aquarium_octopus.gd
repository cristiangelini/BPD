class_name AquariumOctopus
extends StaticBody3D

## Doña Tinta, the octopus lady (escena-acuario.md, "Las pistas"), in her dark tank: her body is the tank's glass, so
## E on the glass is E on her. She is the witness: given a crab (AquariumCrab), she draws in ink on the glass the
## animal of the tank the thief looks after, if she knows (the witness is one of the case's clues). Tapping the glass
## (E with empty hands) or shouting near her sends her into her cave for HIDE_SECONDS, and the drawing goes with her;
## the second time she takes offense for good, and says nothing more. Every number here is (propuesta).

const MODEL := preload("res://assets/models/octopus_tinta.glb")
const HIDE_SECONDS := 60.0
## She takes offense for good the second time she has to hide.
const OFFENSES := 2
## A shout this close to her tank scares her, in meters.
const SHOUT_REACH := 6.0
const INK := Color(0.06, 0.04, 0.16)
const EYE := Color(0.85, 0.85, 0.9)
## Her strokes over the animal's body (Aquarium.animal_mesh), on the glass: [center, size, turn, eye?]. The ray has no
## body: it is all strokes, a diamond with a tail.
const STROKES := {
	"sharks": [[Vector2(0, -0.2), Vector2(0.9, 0.12), 0.0], [Vector2(0.48, -0.2), Vector2(0.08, 0.3), 0.0],
		[Vector2(-0.33, -0.19), Vector2(0.04, 0.04), 0.0, true]],
	"jellyfish": [[Vector2(-0.12, -0.12), Vector2(0.012, 0.24), 0.0], [Vector2(-0.04, -0.14), Vector2(0.012, 0.28), 0.0],
		[Vector2(0.04, -0.13), Vector2(0.012, 0.26), 0.0], [Vector2(0.12, -0.12), Vector2(0.012, 0.24), 0.0]],
	"turtles": [[Vector2(-0.36, 0), Vector2(0.14, 0.1), 0.0], [Vector2(-0.18, -0.12), Vector2(0.07, 0.12), 0.3],
		[Vector2(0.18, -0.12), Vector2(0.07, 0.12), -0.3], [Vector2(-0.38, 0.01), Vector2(0.03, 0.03), 0.0, true]],
	"rays": [[Vector2(0, 0), Vector2(0.4, 0.4), PI / 4], [Vector2(0.48, 0), Vector2(0.4, 0.02), 0.0],
		[Vector2(-0.08, 0.06), Vector2(0.04, 0.04), 0.0, true], [Vector2(0.08, 0.06), Vector2(0.04, 0.04), 0.0, true]],
	"seahorses": [[Vector2(-0.13, 0.11), Vector2(0.14, 0.04), 0.0], [Vector2(0.05, -0.2), Vector2(0.06, 0.1), 0.8],
		[Vector2(0.09, -0.24), Vector2(0.08, 0.03), 0.0], [Vector2(-0.02, 0.1), Vector2(0.03, 0.03), 0.0, true]],
	"penguins": [[Vector2(-0.19, 0.14), Vector2(0.1, 0.04), 0.0], [Vector2(-0.17, -0.02), Vector2(0.05, 0.22), -0.4],
		[Vector2(0.17, -0.02), Vector2(0.05, 0.22), 0.4], [Vector2(0, -0.27), Vector2(0.22, 0.04), 0.0],
		[Vector2(-0.06, 0.15), Vector2(0.04, 0.04), 0.0, true], [Vector2(0, -0.04), Vector2(0.14, 0.22), 0.0, true]],
}
## Where she sits, and where she hides: back in her rock cave.
const SEAT := Vector3(0, 0.05, 0)
const CAVE := Vector3(-0.6, 0.05, -0.4)

## The size of her tank's glass, which is her body, in her own axes (she faces +Z), with its bottom at her feet.
var glass := Vector3(2.6, 2.2, 3.4)
var case: CrimeSceneCase
## She saw the thief: the witness is one of the case's clues.
var knows := false
## The animal she draws (the culprit's tank).
var animal := ""
var hidden_left := 0.0
var offenses := 0
var offended := false
var drawing: Node3D
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("aquarium_octopus")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = glass
	shape.shape = box
	shape.position.y = glass.y / 2
	add_child(shape)
	_model = MODEL.instantiate()
	_model.position = SEAT
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = glass.y + 0.4
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	if offended:
		return "PROMPT_OCTOPUS_OFFENDED"
	return "PROMPT_OCTOPUS_HIDDEN" if is_hidden() else "PROMPT_OCTOPUS_TAP"


## E with empty hands: a tap on the glass. She doesn't like it.
func use(_cop: Cop) -> void:
	if offended:
		say("OCTOPUS_OFFENDED")
		return
	hide_away()


func is_hidden() -> bool:
	return hidden_left > 0.0


## A crab for her: out of her cave and not offended, she eats it and draws (or shrugs, if she saw nothing). Returns
## whether she took it.
func feed(_cop: Cop) -> bool:
	if offended:
		say("OCTOPUS_OFFENDED")
		return false
	if is_hidden():
		say("OCTOPUS_HIDDEN")
		return false
	if not knows or not case:
		say("OCTOPUS_NOTHING")
		return true
	draw_animal()
	say("OCTOPUS_DRAWS")
	case.found("witness")
	return true


## The thief's tank animal in ink on the inside of the glass, facing the hall.
func draw_animal() -> void:
	if drawing:
		drawing.queue_free()
	drawing = Node3D.new()
	drawing.name = "Drawing"
	drawing.position = Vector3(0, glass.y * 0.6, glass.z / 2 - 0.08)
	# Big and flat on the glass.
	drawing.scale = Vector3(2.5, 2.5, 0.1)
	add_child(drawing)
	var ink := StandardMaterial3D.new()
	ink.albedo_color = INK
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var eye := StandardMaterial3D.new()
	eye.albedo_color = EYE
	eye.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if animal != "rays":
		var shape := MeshInstance3D.new()
		shape.mesh = Aquarium.animal_mesh(animal)
		shape.material_override = ink
		drawing.add_child(shape)
	for stroke: Array in STROKES.get(animal, []):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(stroke[1].x, stroke[1].y, 0.06)
		line.mesh = box
		line.position = Vector3(stroke[0].x, stroke[0].y, 0.2)
		line.rotation.z = stroke[2]
		line.material_override = ink if stroke.size() < 4 else eye
		drawing.add_child(line)


## Back into her cave for HIDE_SECONDS, rubbing out her drawing; the second time, offended for good.
func hide_away() -> void:
	if offended:
		return
	hidden_left = HIDE_SECONDS
	_model.position = CAVE
	_model.scale = Vector3.ONE * 0.6
	if drawing:
		drawing.queue_free()
		drawing = null
	offenses += 1
	if offenses >= OFFENSES:
		offend()
	else:
		say("OCTOPUS_HIDES")


func offend() -> void:
	if offended:
		return
	offended = true
	say("OCTOPUS_OFFENDED")
	if knows and case:
		case.ruin("witness")


## A cop shouted: if he was close, she hides.
func shouted_by(cop: Cop) -> void:
	if cop and cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		hide_away()


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if hidden_left > 0.0:
		hidden_left -= delta
		if hidden_left <= 0.0 and not offended:
			_model.position = SEAT
			_model.scale = Vector3.ONE
