class_name Chamois
extends Grabbable

## A dry chamois from the car wash's rag basket (docs/diseno/allanamiento-lavadero.md, "Pompita"): Pompita talks to
## whoever brings him one still dry. Through the running tunnel's jets, or dropped in a puddle, it gets wet: darker,
## dripping, and no use to him anymore.

signal got_wet

const DRY := Color(0.95, 0.82, 0.45)
const WET := Color(0.55, 0.45, 0.25)

var dry := true
var _drops: Label3D


func _ready() -> void:
	_tint(DRY)
	_drops = Label3D.new()
	_drops.text = "CARWASH_CHAMOIS_WET"
	_drops.font_size = 48
	_drops.pixel_size = 0.005
	_drops.outline_size = 10
	_drops.modulate = Color(0.55, 0.8, 1.0)
	_drops.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_drops.position = Vector3(0, 0.2, 0)
	_drops.visible = false
	add_child(_drops)


func soak() -> void:
	if not dry:
		return
	dry = false
	_tint(WET)
	_drops.visible = true
	get_tree().create_timer(2.0).timeout.connect(func() -> void: _drops.visible = false)
	got_wet.emit()


## Online, the guests' copy has the host's name, so the host can say which chamois got wet (CarWash.net_state).
func net_setup() -> Dictionary:
	return {"name": name}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CARWASH_CHAMOIS_HELD" if dry else ""


func _tint(color: Color) -> void:
	var look := get_node_or_null("Model") as MeshInstance3D
	if look:
		var paint := StandardMaterial3D.new()
		paint.albedo_color = color
		look.material_override = paint
