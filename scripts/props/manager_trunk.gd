class_name ManagerTrunk
extends StaticBody3D

## The trunk of the bank manager's car when he's the gang's boss (robo-banco-gerente.md, step 2, decision 124): it
## waits open, with empty sacks inside, for the money. E closes it; a while later the manager opens it again "so it
## airs out". Built as a child of his car, in the car's frame (the model faces +Z, so the trunk is at -Z).
## Every number here is (propuesta).

signal closed_by(cop: Cop)

const BAG_MODEL := preload("res://assets/models/money_bag.glb")
## The lid's hinge, at the back of the cabin over the trunk, and how far it swings open (radians).
const HINGE := Vector3(0, 0.97, -1.22)
const LID_SIZE := Vector3(2.0, 0.05, 1.06)
const OPEN_ANGLE := 1.75
const SWING_TIME := 0.4
## Closed, he opens it again after this long (s).
const REOPEN := 6.0
const PAINT := Color(0.48, 0.12, 0.18)

## The manager, who opens it again.
var manager: BankManager
var is_open := true
var _lid: Node3D
var _reopen_left := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	# A bit past the car's own box at the back, so E from behind the car finds the trunk.
	box.size = Vector3(2.0, 0.6, 1.25)
	shape.shape = box
	shape.position = Vector3(0, 0.95, -1.85)
	add_child(shape)
	var hole := MeshInstance3D.new()
	hole.name = "Hole"
	var hole_mesh := BoxMesh.new()
	hole_mesh.size = Vector3(1.8, 0.02, 0.9)
	hole.mesh = hole_mesh
	hole.material_override = _material(Color(0.08, 0.08, 0.09))
	hole.position = Vector3(0, 0.96, -1.76)
	add_child(hole)
	for i in 2:
		var x := -0.45 if i == 0 else 0.4
		var bag: Node3D = BAG_MODEL.instantiate()
		bag.name = "EmptyBag%d" % (i + 1)
		bag.position = Vector3(x, 0.97, -1.75)
		bag.rotation = Vector3(PI / 2, 0.3 * x, 0)
		bag.scale = Vector3(0.7, 0.7, 0.35)
		add_child(bag)
	_lid = Node3D.new()
	_lid.name = "Lid"
	_lid.position = HINGE
	_lid.rotation.x = OPEN_ANGLE
	add_child(_lid)
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = LID_SIZE
	lid.mesh = lid_mesh
	lid.material_override = _material(PAINT)
	lid.position = Vector3(0, 0, -LID_SIZE.z / 2)
	_lid.add_child(lid)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CLOSE_TRUNK" if is_open else ""


## E: shut. The manager opens it again in REOPEN seconds.
func use(cop: Cop) -> void:
	if not is_open:
		return
	_swing(false)
	_reopen_left = REOPEN
	closed_by.emit(cop)


func _physics_process(delta: float) -> void:
	if is_open or _reopen_left <= 0.0:
		return
	_reopen_left -= delta
	if _reopen_left <= 0.0 and manager and not manager.caught:
		_swing(true)
		manager.say("MANAGER_TRUNK")


## A guest's trunk shows the host's (BankCase.snapshot).
func set_open(open: bool) -> void:
	_reopen_left = 0.0
	_swing(open)


func _swing(open: bool) -> void:
	is_open = open
	var tween := create_tween()
	tween.tween_property(_lid, "rotation:x", OPEN_ANGLE if open else 0.0, SWING_TIME).set_trans(Tween.TRANS_SINE)
