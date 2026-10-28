class_name TippingWardrobe
extends StaticBody3D

## A showroom wardrobe of the furniture store (docs/diseno/allanamiento-muebleria.md, step 1b): too heavy for one cop.
## When two different cops pull it (E) within PAIR_WINDOW seconds of each other, it tips over onto its front and lies
## there, 0.6 m high: a bridge to climb or a barricade. Every number here is (propuesta).

signal tipped

## The two pulls must come this close together.
const PAIR_WINDOW := 1.5
const TIP_SECONDS := 0.6
## The box it stands on: its front-bottom edge is the hinge it tips over.
const SIZE := Vector3(1.2, 2.0, 0.6)

var is_tipped := false
## Who pulled last, and when (in seconds of the game's clock).
var _last_cop: Cop
var _last_at := -INF
var _standing: Transform3D


func prompt_key(_cop: Cop) -> String:
	return "" if is_tipped else "PROMPT_PULL_WARDROBE"


func use(cop: Cop) -> void:
	if is_tipped:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if _last_cop and _last_cop != cop and now - _last_at <= PAIR_WINDOW:
		tip()
		return
	_last_cop = cop
	_last_at = now
	cop.show_hint("HINT_WARDROBE_TOO_HEAVY")


## Tips it over onto its front, turning about its front-bottom edge.
func tip() -> void:
	if is_tipped:
		return
	is_tipped = true
	_standing = transform
	var tween := create_tween()
	tween.tween_method(_lean, 0.0, PI / 2, TIP_SECONDS).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tipped.emit()


## Leaning `angle` forward: the standing pose turned about the hinge, the top toward its front (+Z).
func _lean(angle: float) -> void:
	var hinge := Vector3(0, 0, SIZE.z / 2)
	transform = _standing * Transform3D(Basis(Vector3.RIGHT, angle), hinge) * Transform3D(Basis.IDENTITY, -hinge)
