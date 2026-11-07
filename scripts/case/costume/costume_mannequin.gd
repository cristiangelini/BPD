class_name CostumeMannequin
extends Grabbable

## A shop mannequin in costume (allanamiento-disfraces.md, step 2): 12 kg, it's pushed, grabbed and thrown like any
## loose body. Top-heavy, it tips over when hit hard, and one that is moving fast when it hits another knocks that one
## over too, like bowling pins. Every number here is (propuesta).

## It just ended up on the floor (it can be stood up again and fall again).
signal fell(mannequin: CostumeMannequin)

const LOOKS := {
	"pirate": preload("res://assets/models/mannequin_pirate.glb"),
	"chicken": preload("res://assets/models/mannequin_chicken.glb"),
	"astronaut": preload("res://assets/models/mannequin_astronaut.glb"),
	"vampire": preload("res://assets/models/mannequin_vampire.glb"),
}
const KG := 12.0
const SIZE := Vector3(0.6, 1.55, 0.5)
## Speed it needs to knock over the mannequin it hits, and the push it gives it, at its top.
const KNOCK_SPEED := 1.5
const KNOCK_PUSH := 25.0
## Leaning more than this (cosine of the angle from upright) it's on the floor; back over STAND it's standing again.
const DOWN := 0.5
const STAND := 0.9

@export var look := "pirate"
var down := false


func _ready() -> void:
	add_to_group("costume_mannequins")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0, SIZE.y * 0.65, 0)
	contact_monitor = true
	max_contacts_reported = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child((LOOKS[look] as PackedScene).instantiate())
	body_entered.connect(_on_hit)


## Where its body is, wherever it lies (global): the middle of its height.
func middle() -> Vector3:
	return to_global(Vector3(0, SIZE.y / 2, 0))


func is_upright() -> bool:
	return global_basis.y.dot(Vector3.UP) > STAND


## Pushes it over toward `direction` (global, flat), from its top.
func knock(direction: Vector3) -> void:
	sleeping = false
	var flat := Vector3(direction.x, 0, direction.z).normalized()
	apply_impulse(flat * KNOCK_PUSH, global_basis.y * SIZE.y * 0.9)


func _on_hit(body: Node) -> void:
	var other := body as CostumeMannequin
	if other == null or not other.is_upright():
		return
	# Already tipping it takes the other one with it; standing, only if it comes in fast (thrown or shoved).
	if is_upright() and linear_velocity.length() < KNOCK_SPEED:
		return
	other.knock(other.global_position - global_position)


func _physics_process(delta: float) -> void:
	super(delta)
	var up := global_basis.y.dot(Vector3.UP)
	if not down and up < DOWN:
		down = true
		fell.emit(self)
	elif down and up > STAND:
		down = false
