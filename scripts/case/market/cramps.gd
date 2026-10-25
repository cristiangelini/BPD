class_name Cramps
extends Node

## Cramps from a sample with laxative (politico-mercado.md, step 4, decision 120): for SECONDS the cop walks at half
## speed, the view sways and the tummy rumbles over their head for everyone else to see. Locking themselves in the
## chemical toilet for ChemicalToilet.CURE_TIME cures them (cure). Hangs off the cop as "Cramps". Every number here is
## (propuesta).

const SECONDS := 40.0
const SLOW := 0.5
## The view sways this much (radians) this fast.
const SWAY := 0.07
const SWAY_SPEED := 2.5
const RUMBLES := 3
const RUMBLE_EVERY := 4.0

var cop: Cop
var left := SECONDS
var _time := 0.0
var _rumble_left := 0.0
var _line := 0
var _label: Label3D


static func of(body: Cop) -> Cramps:
	return body.get_node_or_null("Cramps") as Cramps


## Gives `body` cramps, or starts them over.
static func give(body: Cop) -> Cramps:
	var cramps := of(body)
	if cramps:
		cramps.left = SECONDS
		return cramps
	cramps = Cramps.new()
	cramps.name = "Cramps"
	cramps.cop = body
	body.add_child(cramps)
	body.show_hint("HINT_CRAMPS")
	return cramps


static func cure(body: Cop) -> void:
	var cramps := of(body)
	if cramps:
		cramps.stop()


func _ready() -> void:
	_label = Label3D.new()
	_label.name = "Rumble"
	_label.position = Vector3(0, 1.8, 0)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.pixel_size = 0.005
	_label.font_size = 48
	_label.outline_size = 10
	_label.modulate = Color(0.75, 1.0, 0.45)
	_label.hide()
	# Everyone else sees the rumble; the cop's own camera skips their body's layer.
	_label.layers = 1 << (Cop.OWN_BODY_LAYER - 1)
	cop.add_child(_label)


func stop() -> void:
	cop.slow_factor = 1.0
	cop.camera.rotation.z = 0.0
	_label.queue_free()
	queue_free()


func _process(delta: float) -> void:
	left -= delta
	if left <= 0.0:
		stop()
		return
	_time += delta
	cop.slow_factor = SLOW
	cop.camera.rotation.z = sin(_time * SWAY_SPEED) * SWAY
	_rumble_left -= delta
	if _rumble_left <= 0.0:
		_rumble_left = RUMBLE_EVERY
		_label.text = "CRAMPS_RUMBLE_%d" % (_line % RUMBLES + 1)
		_line += 1
	_label.visible = _rumble_left > RUMBLE_EVERY / 2
	_label.position.x = sin(_time * 9.0) * 0.05
