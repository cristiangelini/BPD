class_name GymPunchBag
extends StaticBody3D

## A punching bag of the gym raid's hall, for the fixed fights story (allanamiento-gimnasio.md, "El ring de las peleas
## arregladas"): E punches it, it swings ("¡Pum!", or "¡CLANG!" if there's metal inside) and shoves away whoever stands
## right behind it. `look` is the bag's model in the hall, which swings. Every number here is (propuesta).

signal punched(cop: Cop)

const SIZE := Vector3(0.5, 1.2, 0.5)
## The bag hangs this high (its middle, from the floor).
const MIDDLE := 1.1
const SWING := 0.3
const SWING_TIME := 0.25
## A cop this close behind the bag (away from the puncher) gets shoved this hard (m/s) and staggers.
const BEHIND := 1.3
const SHOVE := 6.0
const SHOVE_TIME := 0.8

## Whether it has something metal inside (it clangs).
var metal := false
var look: Node3D
var punches := 0


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = MIDDLE
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PUNCH_BAG"


func use(cop: Cop) -> void:
	punches += 1
	var away := global_position - cop.global_position
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else Vector3.FORWARD
	if look:
		var tween := look.create_tween()
		var tilt := Vector3(away.z, 0, -away.x) * SWING
		tween.tween_property(look, "rotation", tilt, SWING_TIME).set_trans(Tween.TRANS_SINE)
		tween.tween_property(look, "rotation", Vector3.ZERO, SWING_TIME * 2).set_trans(Tween.TRANS_SINE)
	_word("GYM_BAG_CLANG" if metal else "GYM_BAG_THUD")
	for node in get_tree().get_nodes_in_group("cops"):
		var other := node as Cop
		var to := other.global_position - global_position
		to.y = 0.0
		if other != cop and to.length() < BEHIND and to.dot(away) > 0.0:
			other.knock_back(away * SHOVE + Vector3.UP * 1.5, SHOVE_TIME)
	punched.emit(cop)


func _word(key: String) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 56
	label.pixel_size = 0.008
	label.outline_size = 12
	label.modulate = Color(0.8, 0.85, 0.95) if metal else Color(1, 0.85, 0.4)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, MIDDLE + 1.0, 0)
	add_child(label)
	get_tree().create_timer(1.5).timeout.connect(label.queue_free)
