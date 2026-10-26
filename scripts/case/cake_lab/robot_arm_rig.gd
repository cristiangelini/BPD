class_name RobotArmRig
extends CakeLabRig

## The robot arm (laboratorio.md, "El brazo robot"): the chef stole the decorating arm of the factory next door and
## sells its cakes as handmade. The arm is the main evidence (15 kg, between two), in plain sight decorating on a kitchen
## counter; the remote control and the manual in another language are hidden. While it stands on its counter it
## swings, and every SPLAT_EVERY seconds it throws cream in the face of the nearest cop within SPLAT_RANGE: CREAM_TIME
## seconds unable to see. The story's own clue: a cake on the next counter with oil stains in its cream. Every number
## here is (propuesta).

signal creamed(cop: Cop)

const ARM_SCENE := preload("res://scenes/props/robot_arm.tscn")
const CAKE_MODEL := preload("res://assets/models/bakery_cake.glb")
const ARM_AT := Vector3(CakeLab.COUNTER_X + 1.5, CakeLab.FLOOR_TOP + CakeLab.COUNTER_SIZE.y + 0.415,
	CakeLab.COUNTER_ROWS[2])
const OILY_CAKE_AT := Vector3(CakeLab.COUNTER_X - 1.0, CakeLab.FLOOR_TOP + CakeLab.COUNTER_SIZE.y,
	CakeLab.COUNTER_ROWS[1])
## Farther than this from its counter, the arm is being carried off and stops.
const HOME_RANGE := 0.6
const SPLAT_EVERY := 3.0
const SPLAT_RANGE := 1.8
const CREAM_TIME := 2.0
const SWING := 0.9
const CREAM := Color(0.98, 0.93, 0.9, 0.97)

var arm: Evidence
var oily_cake: OilyCake
var splats := 0
## Cop -> seconds of cream left on their face.
var cream_left := {}
var _since_splat := 0.0
var _time := 0.0
var _model: Node3D
var _screen: ColorRect


func setup(place: CakeLab) -> void:
	super.setup(place)
	arm = ARM_SCENE.instantiate()
	arm.position = ARM_AT
	place.add_child(arm)
	place.main = arm
	_model = arm.get_node("Model")
	oily_cake = OilyCake.new()
	oily_cake.position = OILY_CAKE_AT
	place.add_child(oily_cake)
	oily_cake.looked.connect(func() -> void: place.raid.add_clue(tr("CLUE_OIL_CREAM")))
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_screen = ColorRect.new()
	_screen.color = CREAM
	_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen.hide()
	layer.add_child(_screen)


## The arm is on its counter and nobody holds it: it decorates.
func is_working() -> bool:
	return is_instance_valid(arm) and not arm.is_held() and arm.global_position.distance_to(ARM_AT) < HOME_RANGE


func is_creamed(cop: Cop) -> bool:
	return cream_left.get(cop, 0.0) > 0.0


## Cream in the face of `cop`: CREAM_TIME seconds unable to see.
func cream(cop: Cop) -> void:
	splats += 1
	cream_left[cop] = CREAM_TIME
	cop.show_hint("HINT_CREAM_FACE")
	creamed.emit(cop)


func _physics_process(delta: float) -> void:
	var blind := false
	for seen: Variant in cream_left.keys():
		cream_left[seen] -= delta
		if not is_instance_valid(seen) or cream_left[seen] <= 0.0:
			cream_left.erase(seen)
		elif _is_mine(seen as Cop):
			blind = true
	_screen.visible = blind
	if not is_working():
		return
	_time += delta
	_model.rotation.y = sin(_time * 1.5) * SWING
	_since_splat += delta
	if _since_splat < SPLAT_EVERY:
		return
	var nearest: Cop = null
	var best := SPLAT_RANGE
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		# Each PC creams its own player's cop: the cream only covers that player's screen.
		if not cop or cop.vehicle or is_creamed(cop) or not lab.is_ancestor_of(cop) or not _is_mine(cop):
			continue
		var gap := Vector2(cop.global_position.x - ARM_AT.x, cop.global_position.z - ARM_AT.z).length()
		if gap < best:
			best = gap
			nearest = cop
	if nearest:
		_since_splat = 0.0
		cream(nearest)


## This PC's player's cop (offline, every cop).
static func _is_mine(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()


## The cake with oil in its cream: E looks at it closely.
class OilyCake:
	extends StaticBody3D

	signal looked

	var was_seen := false

	func _ready() -> void:
		var shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = 0.18
		cylinder.height = 0.18
		shape.shape = cylinder
		shape.position.y = 0.09
		add_child(shape)
		var model: Node3D = CAKE_MODEL.instantiate()
		model.position.y = 0.09
		add_child(model)
		for at: Vector3 in [Vector3(0.06, 0.185, 0.03), Vector3(-0.07, 0.185, -0.04)]:
			var stain := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.04
			mesh.bottom_radius = 0.04
			mesh.height = 0.005
			var look := StandardMaterial3D.new()
			look.albedo_color = Color(0.15, 0.13, 0.1)
			look.metallic = 0.6
			look.roughness = 0.2
			mesh.material = look
			stain.mesh = mesh
			stain.position = at
			add_child(stain)

	func prompt_key(_cop: Cop) -> String:
		return "PROMPT_OILY_CAKE"

	func use(cop: Cop) -> void:
		cop.show_hint("CLUE_OIL_CREAM")
		if not was_seen:
			was_seen = true
			looked.emit()
