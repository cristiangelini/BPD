class_name GalleryPolisher
extends StaticBody3D

## The museum's automatic floor polisher (escena-museo.md, "Las pistas"): once a cop walks into the gallery it starts
## going round the waxed floor, and wherever it passes, the footprint (FlourPrint) is gone. E switches it off (and on).
## Every number here is (propuesta).

const SPEED := 1.2
## The footprint this close to its middle gets polished away, in meters.
const REACH := 0.6
const BODY := Color(0.85, 0.75, 0.2)
const PAD := Color(0.2, 0.2, 0.22)

## The corners of its round, in the museum's space, gone through in order and back to the first.
var route: Array[Vector3] = []
var running := false
var switched_off := false
var footprint: FlourPrint
var _next := 1


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.5, 0.6)
	shape.shape = box
	shape.position.y = 0.25
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	var pad := CylinderMesh.new()
	pad.top_radius = 0.3
	pad.bottom_radius = 0.3
	pad.height = 0.08
	builder.mesh(pad, Vector3(0, 0.04, 0), PAD)
	builder.mesh_box(Vector3(0, 0.25, 0), Vector3(0.45, 0.3, 0.45), BODY)
	builder.mesh_box(Vector3(0, 0.75, -0.2), Vector3(0.05, 0.8, 0.05), PAD)
	if not route.is_empty():
		position = route[0]


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ROBOT_POLISHER_ON" if switched_off else "PROMPT_ROBOT_POLISHER_OFF"


func use(cop: Cop) -> void:
	switched_off = not switched_off
	cop.show_hint("HINT_ROBOT_POLISHER_ON" if not switched_off else "HINT_ROBOT_POLISHER_OFF")


## One step along its round, and the footprint if it's under it.
func polish(delta: float) -> void:
	if route.size() < 2:
		return
	var target := route[_next]
	var step := SPEED * delta
	if position.distance_to(target) <= step:
		position = target
		_next = (_next + 1) % route.size()
	else:
		position = position.move_toward(target, step)
	if footprint and not footprint.wiped:
		var off := footprint.position - position
		if Vector2(off.x, off.z).length() <= REACH:
			footprint.wipe()


func _physics_process(delta: float) -> void:
	if running and not switched_off:
		polish(delta)
