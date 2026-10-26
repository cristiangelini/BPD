class_name MessengerPigeon
extends StaticBody3D

## One of Mr. Bellini's trained pigeons (edificio.md, "Las palomas mensajeras"): it flies in from over the street to
## the loft's landing board, waits there STAY seconds and flies off again. It may carry something on its leg; E on it
## while it waits takes it. The pigeons rig scares it off when a cop makes noise. Every number here is (propuesta).

signal landed
signal left
signal gave

enum State { AWAY, ARRIVING, LANDED, LEAVING }

const FLY_TIME := 4.0
const STAY := 12.0
const MODEL := preload("res://assets/models/pigeon.glb")

var state := State.AWAY
## Whether it brings something on its leg.
var carries := false
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _t := 0.0
var _waited := 0.0
var _model: Node3D
var _parcel: MeshInstance3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.25, 0.3)
	shape.shape = box
	shape.position.y = 0.12
	add_child(shape)
	_model = MODEL.instantiate()
	_model.rotation.y = PI / 2
	add_child(_model)
	_parcel = MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.94, 0.9)
	mesh.material = material
	_parcel.mesh = mesh
	_parcel.position = Vector3(0, 0.02, 0)
	add_child(_parcel)
	visible = false
	shape.disabled = true


## Comes from `far` (global) to land at `perch` (global), with or without something on its leg.
func arrive(far: Vector3, perch: Vector3, with_parcel: bool) -> void:
	carries = with_parcel
	_fly(far, perch, State.ARRIVING)


func leave() -> void:
	if state == State.LANDED or state == State.ARRIVING:
		_fly(global_position, global_position + (_from - _to), State.LEAVING)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PIGEON_TAKE" if state == State.LANDED and carries else ""


## Takes what it carries (the pigeons rig drops it on the board) and it flies off.
func use(_cop: Cop) -> void:
	if state != State.LANDED or not carries:
		return
	carries = false
	gave.emit()
	leave()


func _fly(from: Vector3, to: Vector3, next: State) -> void:
	_from = from
	_to = to
	_t = 0.0
	state = next
	visible = true
	(get_child(0) as CollisionShape3D).disabled = false
	global_position = from


func _physics_process(delta: float) -> void:
	_parcel.visible = carries
	match state:
		State.ARRIVING, State.LEAVING:
			_t = minf(_t + delta / FLY_TIME, 1.0)
			# Over the balcony's parapet: it comes in high and drops onto the board last, and leaves going up first.
			var level := _t * _t * _t if _to.y < _from.y else 1.0 - pow(1.0 - _t, 3.0)
			var across := 1.0 - pow(1.0 - _t, 2.0) if _to.y < _from.y else _t * _t
			var at := _from.lerp(_to, across)
			at.y = lerpf(_from.y, _to.y, level)
			global_position = at
			var ahead := _to - _from
			ahead.y = 0.0
			if ahead.length() > 0.01:
				look_at(at + ahead, Vector3.UP)
			_model.position.y = sin(_t * TAU * 6.0) * 0.03
			if _t >= 1.0:
				if state == State.ARRIVING:
					state = State.LANDED
					_waited = 0.0
					landed.emit()
				else:
					state = State.AWAY
					visible = false
					(get_child(0) as CollisionShape3D).disabled = true
					left.emit()
		State.LANDED:
			_waited += delta
			if _waited >= STAY:
				leave()
