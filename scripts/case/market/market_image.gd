class_name MarketImage
extends Node

## Deputy Lustre's image at the market (politico-mercado.md, step 5, decision 120), instead of the plaza's stains: it
## starts at 100 and goes down when a cop takes a sample from his hand without trying it (SNATCH), when a cop with
## cramps rushes past him in front of everyone (CRAMP_PASS, once every CRAMP_GAP per cop) and when a cop cuffs an
## innocent vendor or a shopper (WRONG_CUFF). Each point lost is pay lost at the end (step 6). A line under the walk's
## bar shows it. Every number here is (propuesta).

signal changed(value: float)

const START := 100.0
const SNATCH := 10.0
const CRAMP_PASS := 5.0
const WRONG_CUFF := 20.0
const CRAMP_REACH := 3.0
const CRAMP_GAP := 10.0

var value := START
var tour: MarketTour
## Online, a guest's image: the host's says how much is left (MarketCase snapshot).
var follower := false
var _gaps := {}
var _label: Label


func setup(the_tour: MarketTour, samples: MarketSamples, spite: MarketSpite) -> void:
	tour = the_tour
	samples.snatched.connect(func(_index: int) -> void: lose(SNATCH))
	spite.wrong_cuff.connect(func(_who: Node3D) -> void: lose(WRONG_CUFF, "MARKET_LUSTRE_WRONG_CUFF"))


func _ready() -> void:
	var hud := CanvasLayer.new()
	hud.name = "ImageHud"
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_label.offset_top = 84.0
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_constant_override("outline_size", 6)
	hud.add_child(_label)
	add_child(hud)
	_show()


func lose(points: float, line := "") -> void:
	if follower or points <= 0.0:
		return
	value = maxf(value - points, 0.0)
	if line != "":
		tour.politician.say(line)
	changed.emit(value)
	_show()


## A guest's image: what the host's shows.
func follow(points: float) -> void:
	if is_equal_approx(points, value):
		return
	value = points
	changed.emit(value)
	_show()


func lost() -> float:
	return START - value


func _physics_process(delta: float) -> void:
	for cop: Variant in _gaps.keys():
		_gaps[cop] = maxf(_gaps[cop] - delta, 0.0)
	if follower or tour.state == MarketTour.State.WAITING or tour.state == MarketTour.State.OVER:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if _gaps.get(cop, 0.0) > 0.0 or not Cramps.of(cop):
			continue
		if cop.global_position.distance_to(tour.politician.global_position) < CRAMP_REACH:
			_gaps[cop] = CRAMP_GAP
			lose(CRAMP_PASS, "MARKET_LUSTRE_CRAMP_PASS")


func _show() -> void:
	if _label:
		_label.text = tr("HUD_IMAGE") % int(value)
