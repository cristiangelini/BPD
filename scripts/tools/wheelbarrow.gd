class_name Wheelbarrow
extends StaticBody3D

## The armory's wheelbarrow (docs/diseno/comisaria.md, "La armería"): one cop pushes it with E and carries up to
## CAPACITY_KG in it, the heavy evidence one cop can't lift. While pushed it rides in front of the cop, who walks slower
## and squeaks: the grandpa hears it. E on something while pushing loads it, E on nothing parks it and G tips it over,
## dumping what's in it in front. Every number here is (propuesta).

const CAPACITY_KG := 40.0
const SPEED_FACTOR := 0.6
## Where it rides while pushed, in the cop's own coordinates (the cop holds the handles).
const PUSH_AT := Vector3(0, 0, -1.2)
## The tray's floor, where loaded things sit.
const TRAY_Y := 0.47
## How often it squeaks while moving, in seconds.
const SQUEAK_EVERY := 1.0
## The box the pushing cop collides with: the tray, the wheel and the handles.
const SOLID := Vector3(0.72, 0.6, 1.7)
const SOLID_Y := 0.45

## The cop pushing it, if any.
var pusher: Cop
var cargo: Array[Grabbable] = []
var _squeak_left := 0.0
var _cop_shape: CollisionShape3D
## Online on a guest: the host moves what it carries, so what spills out stays a frozen copy (PropSync).
var _follower := false


func load_kg() -> float:
	var kg := 0.0
	for item in cargo:
		kg += item.mass
	return kg


func can_load(item: Grabbable) -> bool:
	return not cargo.has(item) and not item.is_held() and load_kg() + item.mass <= CAPACITY_KG


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_WHEELBARROW_TAKE"


## E on the parked wheelbarrow: grab the handles.
func use(cop: Cop) -> void:
	if cop.ram or cop.get_node("Grabber").held:
		cop.show_hint("ARMORY_HANDS_FULL")
		return
	push(cop)


func push(cop: Cop) -> void:
	pusher = cop
	_follower = cop.sync != null and not cop.sync.net.is_host()
	cop.wheelbarrow = self
	collision_layer = 0
	reparent(cop, false)
	transform = Transform3D(Basis.IDENTITY, PUSH_AT)
	# The cop's body gets the wheelbarrow's box, so it bumps into walls and furniture instead of going through them.
	_cop_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SOLID
	_cop_shape.shape = box
	_cop_shape.position = PUSH_AT + Vector3(0, SOLID_Y, 0)
	cop.add_child(_cop_shape)


## Lets go of the handles: it stays where it is, with its cargo.
func park() -> void:
	if not pusher:
		return
	var level := pusher.get_parent()
	pusher.wheelbarrow = null
	_cop_shape.queue_free()
	pusher = null
	reparent(level, true)
	global_basis = Basis(Vector3.UP, global_rotation.y)
	collision_layer = 1


## Puts `item` in the tray: it rides frozen until dumped or picked up.
func add(item: Grabbable) -> bool:
	if not can_load(item):
		return false
	cargo.append(item)
	item.freeze = true
	item.set_meta("layer", item.collision_layer)
	item.collision_layer = 0
	item.reparent(self, false)
	# Piled up in the middle of the tray, one on top of the other.
	item.transform = Transform3D(Basis.IDENTITY, Vector3(0, TRAY_Y + 0.25 + (cargo.size() - 1) * 0.35, 0))
	return true


## Tips it over: everything slides out in front and the wheelbarrow is parked.
func dump() -> void:
	var level := pusher.get_parent() if pusher else get_parent()
	var ahead := -global_basis.z if not pusher else -pusher.global_basis.z
	var front := global_position + ahead * 1.2 + Vector3.UP * 0.4
	for i in cargo.size():
		var item := cargo[i]
		item.reparent(level, true)
		item.global_position = front + global_basis.x * (i - (cargo.size() - 1) / 2.0) * 0.6
		item.collision_layer = item.get_meta("layer", 4)
		item.freeze = _follower
	cargo.clear()
	park()


func _physics_process(delta: float) -> void:
	if not pusher:
		return
	if Vector2(pusher.velocity.x, pusher.velocity.z).length() < 0.3:
		return
	_squeak_left -= delta
	if _squeak_left <= 0.0:
		_squeak_left = SQUEAK_EVERY
		get_tree().call_group("grandpas", "heard_squeak", global_position)
