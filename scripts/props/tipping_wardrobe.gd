class_name TippingWardrobe
extends StaticBody3D

## A showroom wardrobe of the furniture store (docs/diseno/allanamiento-muebleria.md, step 1b): too heavy for one cop.
## When two different cops pull it (E) within PAIR_WINDOW seconds of each other, it tips over onto its front and lies
## there, 0.6 m high: a bridge to climb or a barricade. Every number here is (propuesta).

signal tipped
## A light one (a story's, step 5) went over with one cop pulling it alone.
signal pulled_alone(cop: Cop)
## A shut one (a story's, step 5) was opened.
signal opened(cop: Cop)

## The two pulls must come this close together.
const PAIR_WINDOW := 1.5
const TIP_SECONDS := 0.6
## The box it stands on: its front-bottom edge is the hinge it tips over.
const SIZE := Vector3(1.2, 2.0, 0.6)

var is_tipped := false
## Made of cardboard (the cardboard wood's story): one cop alone tips it over.
var light := false
## Its doors shut (the wardrobe hotel's story): the first E opens it instead of pulling.
var shut := false
## Who pulled last, and when (in seconds of the game's clock).
var _last_cop: Cop
var _last_at := -INF
var _standing: Transform3D


func prompt_key(_cop: Cop) -> String:
	if shut:
		return "PROMPT_OPEN_WARDROBE"
	return "" if is_tipped else "PROMPT_PULL_WARDROBE"


func use(cop: Cop) -> void:
	if shut:
		shut = false
		opened.emit(cop)
		return
	if is_tipped:
		return
	if light:
		tip()
		pulled_alone.emit(cop)
		return
	# Online the host decides whether two pulls came together (each PC hears them at its own time); the guests take
	# the tipped wardrobes from its state (FurnitureStore.net_state).
	if not multiplayer.is_server():
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
