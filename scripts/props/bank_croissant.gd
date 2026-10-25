class_name BankCroissant
extends Grabbable

## A croissant from the party's tray (robo-banco-rehenes.md, step 4): E with it in hand on a hostage who doesn't want
## to leave gives it to them (they follow at full speed, BankHostage.feed); anywhere else the cop eats it, like a donut
## from the armory. Online the host makes it and eats it (PropSync copies it).

const MODEL := preload("res://assets/models/bank_croissant.glb")


func _ready() -> void:
	mass = 0.1
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.18, 0.07, 0.1)
	shape.shape = box
	shape.position.y = 0.035
	add_child(shape)
	add_child(MODEL.instantiate())


## PropSync makes a guest's copy from the script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_EAT_CROISSANT"


## Eaten by the cop holding it: the stamina full again, as a donut.
func use(cop: Cop) -> void:
	if not multiplayer.is_server():
		return
	cop.get_node("Grabber").release()
	cop.fill_up_on_donut()
	if cop.sync and cop.sync.net.actions and not cop.sync.is_multiplayer_authority():
		cop.sync.net.actions.tell_guests(cop, "fill_up_on_donut", cop)
		cop.sync.tell_held()
	queue_free()


## Given to a hostage: out of the cop's hands and gone.
func given(cop: Cop) -> void:
	if not multiplayer.is_server():
		return
	cop.get_node("Grabber").release()
	if cop.sync and not cop.sync.is_multiplayer_authority():
		cop.sync.tell_held()
	queue_free()
