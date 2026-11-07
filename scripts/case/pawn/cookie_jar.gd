class_name CookieJar
extends StaticBody3D

## The cookie jar on the pawn shop's counter (allanamiento-empenos.md, "Don Regateo y Chicharra"): E takes a cookie for
## Chicharra the parrot, one per cop. The cop carries it until they give it to him.

const MODEL := preload("res://assets/models/cookie_jar.glb")
const SIZE := Vector3(0.2, 0.26, 0.2)

## The cops who took their cookie, and whether they still carry it (cop -> true while carrying).
var took := {}
var carrying := {}


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(cop: Cop) -> String:
	return "" if took.has(cop) else "PROMPT_PAWN_COOKIE"


func use(cop: Cop) -> void:
	if took.has(cop):
		return
	took[cop] = true
	carrying[cop] = true
	cop.show_hint("HINT_PAWN_COOKIE")


func has_cookie(cop: Cop) -> bool:
	return carrying.has(cop)


## `cop` gave their cookie away.
func eat(cop: Cop) -> void:
	carrying.erase(cop)
