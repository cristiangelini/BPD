class_name CocoaCup
extends Grabbable

## A cup of hot chocolate from the rink's bar (docs/diseno/allanamiento-pista.md, "Copito"): Copito talks to whoever
## brings him one still full. Tilted too much, or bumped hard (a fall, a wall, a throw), it spills and is just an empty
## cup. Every number here is (propuesta).

signal spilled

## Tilted past this (the cosine of the angle from upright) it spills; hit at this speed too.
const SPILL_TILT := 0.5
const SPILL_SPEED := 3.0
const STEAM := Color(1.0, 1.0, 1.0, 0.6)

var full := true
var _speed := 0.0
var _steam: Label3D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(func(_body: Node) -> void:
		if _speed > SPILL_SPEED:
			spill())
	_steam = Label3D.new()
	_steam.text = "~"
	_steam.font_size = 40
	_steam.pixel_size = 0.005
	_steam.modulate = STEAM
	_steam.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_steam.position = Vector3(0, 0.14, 0)
	add_child(_steam)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if full and global_basis.y.dot(Vector3.UP) < SPILL_TILT:
		spill()
	_speed = linear_velocity.length()


func spill() -> void:
	if not full:
		return
	full = false
	_steam.text = "RINK_COCOA_SPILLED"
	_steam.font_size = 48
	_steam.modulate = Color(0.55, 0.3, 0.15)
	get_tree().create_timer(2.0).timeout.connect(func() -> void: _steam.visible = false)
	spilled.emit()


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_RINK_COCOA_CUP" if full else ""
