class_name LaughingGasTank
extends Grabbable

## A tank of laughing gas in a consulting room of the dental office (docs/diseno/allanamiento-dentista.md, "El gas de la
## risa"). Knocked over or hit hard, it leaks LEAK_TIME seconds: a pink cloud, and every cop within RANGE laughs out
## loud and can't grab anything for LAUGH seconds (dropping what it holds). Every number here is (propuesta).

signal leaked

const MODEL := preload("res://assets/models/gas_tank.glb")
const KG := 8.0
const RADIUS := 0.1
const HEIGHT := 0.95
const LEAK_TIME := 10.0
## A hit harder than this opens the valve, and so does tipping over (its up further than TIPPED from the world's).
const LEAK_SPEED := 3.0
const TIPPED := 0.5
const RANGE := 3.0
const LAUGH := 5.0
const CLOUD := Color(1.0, 0.6, 0.85, 0.3)

## Seconds of gas left; 0 while closed.
var leak_left := 0.0
var leaks := 0
var _impacts := ImpactTracker.new()
var _was_tipped := false
var _cloud: MeshInstance3D


func _ready() -> void:
	mass = KG
	collision_layer = 4
	collision_mask = 15
	contact_monitor = true
	max_contacts_reported = 4
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS
	cylinder.height = HEIGHT
	shape.shape = cylinder
	shape.position.y = HEIGHT / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	_cloud = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = RANGE * 0.6
	sphere.height = RANGE * 0.9
	_cloud.mesh = sphere
	var look := StandardMaterial3D.new()
	look.albedo_color = CLOUD
	look.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	look.cull_mode = BaseMaterial3D.CULL_DISABLED
	_cloud.material_override = look
	_cloud.top_level = true
	_cloud.visible = false
	add_child(_cloud)


func is_leaking() -> bool:
	return leak_left > 0.0


## Opens the valve: LEAK_TIME seconds of gas (again from the start if it was already leaking).
func leak() -> void:
	leak_left = LEAK_TIME
	leaks += 1
	_cloud.visible = true
	leaked.emit()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	# A guest's frozen copy only follows the host's (the place syncs the leak).
	if speed > LEAK_SPEED and not freeze and not is_leaking():
		leak.call_deferred()


func _physics_process(delta: float) -> void:
	var tipped := global_basis.y.dot(Vector3.UP) < TIPPED
	if tipped and not _was_tipped and not freeze and not is_leaking():
		leak()
	_was_tipped = tipped
	if not is_leaking():
		return
	leak_left = maxf(leak_left - delta, 0.0)
	_cloud.visible = is_leaking()
	_cloud.global_position = global_position + Vector3.UP * 0.6
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		# Each PC makes its own cop laugh.
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		if not cop.is_eating() and cop.global_position.distance_to(global_position) < RANGE:
			cop.eat(LAUGH, "HINT_LAUGHING_GAS")
