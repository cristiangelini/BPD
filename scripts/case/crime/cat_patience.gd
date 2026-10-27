class_name CatPatience
extends Node

## Señora Ofelia's patience (escena-gato.md, "La paciencia de la señora"): a bar at the top while a cop is at the
## mansion, from 100 down with what the cops do (no clock, decision 66). Each time it drops below 75, 50 and 25 she
## phones the comisario, who calls the cops on the radio, terrified, and 50 comes off the salary. At 0 she throws the
## cops out and they can't come back in; they can still accuse at the board with what they have. Duquesa brought home
## gives 30 back. Every number here is (propuesta).

signal thrown_out

const FULL := 100.0
const CALLS: Array[float] = [75.0, 50.0, 25.0]
const CALL_FINE := 50
## How much each thing costs her patience.
const COSTS := {"vase": 15.0, "wrong_cat": 20.0, "wrong_cuff": 15.0, "armchair": 10.0, "shout": 5.0}
const DUCHESS_BACK := 30.0
const TEA := 10.0

var mansion: CatMansion
var case: CrimeSceneCase
var value := FULL
var calls := 0
var out := false
var _hud: CanvasLayer
var _bar: ProgressBar


func _ready() -> void:
	_build_hud()


## The cops did `why` (a key of COSTS): down it goes, with a call to the comisario at each line crossed. She
## complains, unless she already said something (`quiet`).
func lose(why: String, quiet := false) -> void:
	if out or case.follower:
		return
	value = maxf(value - COSTS[why], 0.0)
	if not quiet:
		mansion.lady.say("MANSION_LADY_ANNOYED_" + why)
	while calls < CALLS.size() and value < CALLS[calls]:
		calls += 1
		case.fines += CALL_FINE
		case.comisario_says("CAT_COMISARIO_CALL_%d" % calls)
	if value <= 0.0:
		throw_out()


func gain(amount: float) -> void:
	if not out:
		value = minf(value + amount, FULL)


## "¡Fuera de mi casa!": every cop inside goes out to the garden, and nobody gets back in.
func throw_out() -> void:
	out = true
	mansion.lady.say("MANSION_LADY_OUT")
	case.comisario_says("CAT_COMISARIO_THROWN_OUT")
	thrown_out.emit()


func _physics_process(_delta: float) -> void:
	if not out:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if mansion.inside(cop.global_position):
			cop.warp(Transform3D(mansion.global_basis, mansion.to_global(CatMansion.THROWN_OUT_AT)))


func _process(_delta: float) -> void:
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = cop != null and mansion.at_scene(cop.global_position)
	_bar.value = value


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	box.position = Vector2(-120, 16)
	box.custom_minimum_size = Vector2(240, 0)
	var title := Label.new()
	title.text = "HUD_CAT_PATIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(240, 14)
	_bar.show_percentage = false
	_bar.max_value = FULL
	_bar.modulate = Color(1.0, 0.55, 0.75)
	box.add_child(_bar)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)
