class_name KeyMachine
extends StaticBody3D

## The key copying machine on the hardware store's counter (docs/diseno/ferreteria.md, "Don Cosme"). Once Don Cosme
## asked for his copy, a cop files it with E, PRESSES times, in sparks; then the new key drops on the counter for him.
## The machine is Tobías's: every press he sees raises his complaint. Every number here is (propuesta).

## The copy is done.
signal done(key: Grabbable)

const KEY_SCENE := preload("res://scenes/props/key_copy.tscn")
const SIZE := Vector3(0.5, 0.3, 0.35)
const PRESSES := 4
## Each press Tobías sees: "¡Esa máquina es mía!".
const SEEN_PRESS := 5.0
## Where the new key drops, from the machine's base: on the counter in front of it.
const KEY_DROP := Vector3(0, 0.05, 0.25)

var customer: KeyCustomer
var hardware_man: HardwareMan
var presses := 0
var key: Grabbable
var _sparks: CPUParticles3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position = Vector3.UP * SIZE.y / 2
	add_child(shape)
	_sparks = CPUParticles3D.new()
	_sparks.emitting = false
	_sparks.one_shot = true
	_sparks.amount = 16
	_sparks.lifetime = 0.4
	_sparks.explosiveness = 0.9
	_sparks.direction = Vector3(0, 1, 1)
	_sparks.spread = 50.0
	_sparks.initial_velocity_min = 1.0
	_sparks.initial_velocity_max = 2.5
	var dot := SphereMesh.new()
	dot.radius = 0.01
	dot.height = 0.02
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1.0, 0.75, 0.2)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.6, 0.1)
	dot.material = glow
	_sparks.mesh = dot
	_sparks.position = Vector3(0, SIZE.y + 0.05, 0)
	add_child(_sparks)


func is_done() -> bool:
	return presses >= PRESSES


func prompt_key(_cop: Cop) -> String:
	if is_done() or not customer or not customer.was_asked:
		return ""
	return "PROMPT_KEY_MACHINE"


## One more pass of the file over the key: sparks, and Tobías complains if he sees it. The last one drops the key.
func use(_cop: Cop) -> void:
	if is_done() or not customer or not customer.was_asked:
		return
	presses += 1
	_sparks.restart()
	if hardware_man and hardware_man.can_see(global_position + Vector3.UP * SIZE.y):
		hardware_man.saw_machine(SEEN_PRESS)
	if is_done():
		key = KEY_SCENE.instantiate()
		get_parent().add_child(key)
		key.global_position = to_global(KEY_DROP)
		done.emit(key)
