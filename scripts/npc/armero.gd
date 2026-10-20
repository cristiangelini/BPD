class_name Armero
extends StaticBody3D

## The armero behind the armory counter (docs/diseno/comisaria.md, "La armería"): E on him opens his list for that
## cop, to buy with the common cash box and take what the station owns.

const MODEL := preload("res://assets/models/npc_armero.glb")

## Spends the campaign's cash box when there is one (solo or hosting), else a cash box for this shift only.
var armory := Armory.new(Campaign.current if Campaign.current else StationWallet.new())
var menu: ArmoryMenu


func _ready() -> void:
	add_child(MODEL.instantiate())
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	menu = ArmoryMenu.new()
	add_child(menu)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ARMERO"


func use(cop: Cop) -> void:
	menu.open(armory, cop)
