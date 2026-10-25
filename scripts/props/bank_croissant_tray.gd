class_name BankCroissantTray
extends StaticBody3D

## The party's tray on the bank's counter (robo-banco-rehenes.md, step 4): E with empty hands takes a croissant
## (BankCroissant) into them, until the CROISSANTS are gone. Online every PC takes it off its tray and only the host
## makes the croissant.

const MODEL := preload("res://assets/models/bank_croissant_tray.glb")
const CROISSANTS := 7

var left := CROISSANTS


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 0.12, 0.5)
	shape.shape = box
	shape.position.y = 0.06
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(cop: Cop) -> String:
	if left == 0:
		return "PROMPT_CROISSANTS_GONE"
	return "" if cop.get_node("Grabber").held else "PROMPT_TAKE_CROISSANT"


func use(cop: Cop) -> void:
	if left == 0 or cop.get_node("Grabber").held:
		return
	set_left(left - 1)
	if not multiplayer.is_server():
		return
	var croissant := BankCroissant.new()
	croissant.name = "Croissant%d" % left
	get_parent().add_child(croissant)
	croissant.global_position = global_position + Vector3.UP * 0.15
	cop.handed(croissant)


## How many are still on the tray (the rest hidden, the last ones first).
func set_left(count: int) -> void:
	left = count
	for i in CROISSANTS:
		var part := find_child("croissant_%d" % i, true, false) as Node3D
		if part:
			part.visible = i < left
