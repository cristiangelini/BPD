class_name Watermelon
extends Ornament

## A watermelon from a fruit seller's pickup (control-frutas.md, steps 3 and 4). It rides frozen in the truck's bed
## until a cop grabs it; then it's loose on the street, 8 kg, so one cop can carry it. E on it, in hand or not, is a
## tap: a normal one sounds "toc toc", a hollow one (the smuggler's) or an overripe one sounds odd. Thrown hard to the
## ground it splits open with juice, and shows what's inside: red flesh, the gold watches or brown mush. Every number
## here is (propuesta).

signal tapped(cop: Cop)

const MODEL := preload("res://assets/models/watermelon.glb")
const HALF := preload("res://assets/models/watermelon_half.glb")
const KG := 8.0
## A put-down or a drop from the hands (1.3 m, 5 m/s) doesn't break it; a throw to the ground does.
const SPLIT_SPEED := 5.5
const RADIUS := 0.18
const LONG := 0.52
const FLESH := Color(0.91, 0.22, 0.29)
const MUSH := Color(0.55, 0.4, 0.2)
const JUICE := Color(0.85, 0.12, 0.2, 0.85)
const JUICE_RADIUS := 0.55
## A hollow one holds this many fake gold watches.
const WATCHES := 2
const SAY_SECONDS := 2.0
const KINDS: Array[String] = ["normal", "hollow", "overripe"]

## "normal", "hollow" (the gold watches) or "overripe" (sounds odd too, only mush inside).
var kind := "normal"
## Still in its truck's bed, frozen and riding along.
var in_bed := false
var truck: QueueCar
## It came from the wanted pickup: breaking it is no complaint.
var from_wanted := false
## How many times it's been tapped, for tests and the case.
var taps := 0
var _bubble: Label3D


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	shard_color = FLESH
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = LONG
	shape.shape = capsule
	shape.rotation.x = PI / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	add_child(model)


func _ready() -> void:
	super._ready()
	add_to_group("watermelons")
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.003
	_bubble.font_size = 40
	_bubble.outline_size = 8
	_bubble.position = Vector3(0, 0.45, 0)
	_bubble.hide()
	add_child(_bubble)


## In a truck's bed: frozen, it moves with the truck and doesn't break.
func put_in_bed(car: QueueCar) -> void:
	truck = car
	from_wanted = car.wanted
	in_bed = true
	freeze = true


func hold(holder_id: int, point: Vector3) -> void:
	if in_bed:
		leave_bed()
	super.hold(holder_id, point)


## Off the truck and onto the street, loose.
func leave_bed() -> void:
	if not in_bed:
		return
	in_bed = false
	freeze = false
	var street := truck._street() if is_instance_valid(truck) else get_parent()
	if street and street != get_parent():
		reparent(street, true)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAP_MELON"


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAP_MELON_HELD"


## E: a tap, and how it sounds.
func use(cop: Cop) -> void:
	taps += 1
	say(tr(tap_key()))
	tapped.emit(cop)


## The sound of a tap: odd for a hollow one and for an overripe one alike.
func tap_key() -> String:
	return "MELON_TAP" if kind == "normal" else "MELON_TAP_ODD"


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	get_tree().create_timer(SAY_SECONDS).timeout.connect(_bubble.hide)


## The bubble's text while it shows, for tests.
func saying() -> String:
	return _bubble.text if _bubble.visible else ""


## Online (PropSync): what a guest's copy needs. It sits in the level, not in the bed, and follows the host's.
func net_setup() -> Dictionary:
	return {"name": name, "kind": kind, "from_wanted": from_wanted}


## Only a hard hit splits it, and never in the bed. A frozen one (a guest's copy) only splits when the host's does.
func hit(speed: float) -> bool:
	if (in_bed or freeze) and speed != INF:
		return false
	return super.hit(INF if speed > SPLIT_SPEED else 0.0)


## Split open: the flying bits, two halves, a puddle of juice and what was inside.
func _shatter() -> void:
	# The traffic case hears of it: an innocent fruit seller's is a complaint.
	var case := TrafficCase.of(self) if is_inside_tree() else null
	if case:
		case.melon_broken(self)
	shard_color = MUSH if kind == "overripe" else FLESH
	super._shatter()
	var street := get_parent()
	if street == null:
		return
	var ground := _ground()
	for side in [-1.0, 1.0]:
		var half := MelonHalf.new()
		half.mushy = kind == "overripe"
		street.add_child(half)
		half.global_position = ground + global_basis.x * side * 0.25 + Vector3.UP * 0.02
		half.rotation.y = rotation.y
	var juice := MeshInstance3D.new()
	juice.name = "Juice"
	var disc := CylinderMesh.new()
	disc.top_radius = JUICE_RADIUS
	disc.bottom_radius = JUICE_RADIUS
	disc.height = 0.004
	disc.radial_segments = 12
	juice.mesh = disc
	var material := StandardMaterial3D.new()
	material.albedo_color = MUSH if kind == "overripe" else JUICE
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	juice.material_override = material
	juice.add_to_group("melon_juice")
	street.add_child(juice)
	juice.global_position = ground + Vector3.UP * 0.008
	if kind == "hollow":
		for i in WATCHES:
			var watch := GoldWatch.new()
			street.add_child(watch)
			watch.global_position = ground + global_basis.z * (0.4 * (i * 2 - 1)) + Vector3.UP * 0.03


## The floor under it, or where it is if there's none close.
func _ground() -> Vector3:
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3.DOWN * 2.0, 1)
	var hit_at := get_world_3d().direct_space_state.intersect_ray(query)
	return hit_at.position if hit_at else global_position + Vector3.DOWN * 0.17
