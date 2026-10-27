class_name FarmEgg
extends Grabbable

## An egg from Don Florencio's hens (docs/diseno/allanamiento-granja.md, "Lo frágil"): carried like anything else, it
## breaks when it hits something faster than BREAK_SPEED, leaving a yolk on the ground for a while. `golden` ones are
## painted gold (the golden eggs story). Every number here is (propuesta).

signal broken(at: Vector3)

const MODEL := preload("res://assets/models/farm_egg.glb")
const KG := 0.06
const BREAK_SPEED := 2.5
const YOLK_LIFE := 15.0
const GOLD := Color(0.97, 0.82, 0.25)

var golden := false
var is_broken := false
var _speed := 0.0


## Online, what a guest's copy needs before it's added (PropSync): whether it's painted gold.
func net_setup() -> Dictionary:
	return {"golden": golden}


func _ready() -> void:
	mass = KG
	collision_layer = 4
	collision_mask = 15
	contact_monitor = true
	max_contacts_reported = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.06, 0.08, 0.06)
	shape.shape = box
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.position.y = -0.04
	add_child(look)
	if golden:
		set_meta("golden", true)
		var paint := StandardMaterial3D.new()
		paint.albedo_color = GOLD
		paint.metallic = 0.6
		paint.roughness = 0.3
		for mesh: MeshInstance3D in look.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = paint
	body_entered.connect(_on_hit)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_EGG"


func _physics_process(delta: float) -> void:
	super(delta)
	_speed = linear_velocity.length()


func _on_hit(_body: Node) -> void:
	if not is_broken and not is_held() and _speed > BREAK_SPEED:
		smash()


## Splat: a yolk on the ground and no more egg.
func smash() -> void:
	if is_broken:
		return
	is_broken = true
	var at := global_position
	var yolk := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.12
	disc.bottom_radius = 0.12
	disc.height = 0.005
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.8, 0.15)
	disc.material = material
	yolk.mesh = disc
	get_parent().add_child(yolk)
	yolk.global_position = Vector3(at.x, at.y - 0.035, at.z)
	get_tree().create_timer(YOLK_LIFE).timeout.connect(yolk.queue_free)
	broken.emit(at)
	queue_free()
