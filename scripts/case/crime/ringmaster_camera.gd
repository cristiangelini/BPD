class_name RingmasterCamera
extends Node3D

## The ringmaster's camera on its tripod by the ring (escena-circo.md, "Las pistas"): it recorded last night's
## rehearsal. Its two buttons sit side by side: "play" shows the recording, where the culprit's nose honks as Galleta
## goes (the recording clue: the honk's note); "delete", right next to it, wipes it for good. Every number here is
## (propuesta).

const METAL := Color(0.2, 0.2, 0.22)
const SCREEN := Color(0.35, 0.6, 0.45)
const PLAY := Color(0.3, 0.75, 0.35)
const DELETE := Color(0.85, 0.2, 0.2)

var case: CrimeSceneCase
## The recording is one of the case's clues.
var has_recording := false
var deleted := false
## The buttons' prompt keys, followed by "play" or "delete".
var prompts := "PROMPT_CAMERA_"


func _ready() -> void:
	var builder := PlaceBuilder.new(self)
	for i in 3:
		var leg := BoxMesh.new()
		leg.size = Vector3(0.03, 1.2, 0.03)
		var turn := i * TAU / 3
		builder.mesh(leg, Vector3(sin(turn) * 0.15, 0.6, cos(turn) * 0.15), METAL,
			Vector3(cos(turn) * 0.12, 0, -sin(turn) * 0.12))
	builder.mesh_box(Vector3(0, 1.3, 0), Vector3(0.3, 0.2, 0.18), METAL)
	builder.mesh_box(Vector3(0, 1.3, -0.12), Vector3(0.1, 0.1, 0.08), METAL)
	builder.mesh_box(Vector3(0, 1.3, 0.095), Vector3(0.2, 0.13, 0.01), SCREEN)
	_button("play", Vector3(-0.05, 1.42, 0.03), PLAY)
	_button("delete", Vector3(0.05, 1.42, 0.03), DELETE)


func _button(button: String, at: Vector3, color: Color) -> void:
	var body := CameraButton.new()
	body.name = "Button_" + button
	body.button = button
	body.camera = self
	body.position = at
	add_child(body)
	PlaceBuilder.new(body).mesh_box(Vector3.ZERO, Vector3(0.06, 0.03, 0.06), color)


## "play": the recording, with the culprit's honk if it's a clue and still there.
func play(cop: Cop) -> void:
	if deleted:
		cop.show_hint("HINT_CAMERA_DELETED_ALREADY")
	elif has_recording and case:
		case.found("recording")
		cop.show_hint(tr("HINT_CAMERA_PLAY") % tr("HONK_" + str(case.culprit().honk)))
	else:
		cop.show_hint("HINT_CAMERA_NOTHING")


## "delete": gone for good; if nobody saw it, the clue with it.
func delete(cop: Cop) -> void:
	if deleted:
		if cop:
			cop.show_hint("HINT_CAMERA_DELETED_ALREADY")
		return
	deleted = true
	if cop:
		cop.show_hint("HINT_CAMERA_DELETED")
	if has_recording and case:
		case.ruin("recording")
