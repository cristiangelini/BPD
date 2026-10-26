class_name StatueCoin
extends Grabbable

## A coin from the saucer on the museum's ticket desk (escena-museo.md, "Las pistas"). In hand, E on the living statue
## (LivingStatue) drops it in his hat, and then he talks. Every number here is (propuesta).

const GOLD := Color(0.95, 0.78, 0.3)


func _ready() -> void:
	mass = 0.01
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	# Thicker than it looks, so it doesn't slip through the desk.
	cylinder.radius = 0.04
	cylinder.height = 0.04
	shape.shape = cylinder
	add_child(shape)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.03
	mesh.bottom_radius = 0.03
	mesh.height = 0.008
	PlaceBuilder.new(self).mesh(mesh, Vector3.ZERO, GOLD)


func held_prompt_key(cop: Cop) -> String:
	return "PROMPT_COIN_HAT" if cop._usable_target() is LivingStatue else "PROMPT_HOLDING_COIN"


## E with it in hand: into the statue's hat if the cop aims at him; nothing otherwise.
func use(cop: Cop) -> void:
	var statue := cop._usable_target() as LivingStatue
	if not statue:
		return
	cop.get_node("Grabber").release()
	statue.tip(cop)
	queue_free()
